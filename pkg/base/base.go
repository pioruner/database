package base

import (
	"encoding/json"
	"errors"
	"fmt"
	"reflect"
	"strings"
	"sync"

	//"github.com/glebarez/sqlite"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

type Item struct {
	ID     uint   `gorm:"primaryKey" json:"id" ru:"id"`
	Name   string `json:"name" ru:"Имя"`
	Number string `json:"number" ru:"Номер"`
}

type DB struct {
	mu sync.RWMutex
	db *gorm.DB
}

var allowedFields = generateAllowedFields(Item{})

// generateAllowedFields строит карту допустимых полей
func generateAllowedFields(model interface{}) map[string]string {
	v := reflect.TypeOf(model)
	if v.Kind() != reflect.Struct {
		return nil
	}

	result := make(map[string]string, v.NumField())
	for i := 0; i < v.NumField(); i++ {
		field := v.Field(i)
		colName := gormColumnName(field.Name)
		result[colName] = colName
	}
	return result
}

// gormColumnName переводит CamelCase в snake_case, как делает GORM по умолчанию
func gormColumnName(name string) string {
	var result []rune
	for _, r := range name {
		/*if i > 0 && r >= 'A' && r <= 'Z' {
			result = append(result, '')
		}*/
		result = append(result, r)
	}
	return strings.ToLower(string(result))
}

// generateViewSQL создает SQL для View с кириллическими названиями
func generateViewSQL(viewName, tableName string, model interface{}) (string, error) {
	v := reflect.TypeOf(model)
	if v.Kind() != reflect.Struct {
		return "", fmt.Errorf("ожидалась структура, а не %s", v.Kind())
	}

	columns := make([]string, 0, v.NumField())
	for i := 0; i < v.NumField(); i++ {
		field := v.Field(i)

		// Получаем имя колонки, как его создаст GORM
		colName := gormColumnName(field.Name)

		// Получаем русское название
		ruName := field.Tag.Get("ru")
		if ruName == "" {
			ruName = field.Name // fallback
		}

		columns = append(columns, fmt.Sprintf(`%s AS "%s"`, colName, ruName))
	}

	// Формируем SQL
	sql := fmt.Sprintf(`
DROP VIEW IF EXISTS "%s";
CREATE VIEW "%s" AS
SELECT
    %s
FROM %s;
`, viewName, viewName, strings.Join(columns, ",\n    "), tableName)

	return sql, nil
}

// Open — открыть или создать базу
func (d *DB) Open(path string) error {
	d.mu.Lock()
	defer d.mu.Unlock()

	if d.db != nil {
		_ = d.Close()
	}

	dbConn, err := gorm.Open(sqlite.Open(path), &gorm.Config{PrepareStmt: true})
	if err != nil {
		return err
	}

	if err := dbConn.AutoMigrate(&Item{}); err != nil {
		return err
	}

	// Генерация SQL для View
	viewSQL, err := generateViewSQL("Образцы", "items", Item{})
	if err != nil {
		return err
	}

	// Создание View
	if err := dbConn.Exec(viewSQL).Error; err != nil {
		return err
	}

	d.db = dbConn
	return nil
}

// Close — закрыть базу
func (d *DB) Close() error {
	d.mu.Lock()
	defer d.mu.Unlock()

	if d.db == nil {
		return nil
	}
	sqlDB, err := d.db.DB()
	if err != nil {
		return err
	}
	err = sqlDB.Close()
	d.db = nil
	return err
}

// Add — добавить элемент
func (d *DB) Add(it Item) (uint, error) {
	d.mu.RLock()
	db := d.db
	d.mu.RUnlock()
	if db == nil {
		return 0, errors.New("database not open")
	}
	it.ID = 0
	if err := db.Create(&it).Error; err != nil {
		return 0, err
	}
	return it.ID, nil
}

// DeleteByID — удалить по ID
func (d *DB) DeleteByID(id uint) error {
	d.mu.RLock()
	db := d.db
	d.mu.RUnlock()
	if db == nil {
		return errors.New("database not open")
	}
	return db.Delete(&Item{}, id).Error
}

// Update — обновить элемент
func (d *DB) Update(it Item) error {
	d.mu.RLock()
	db := d.db
	d.mu.RUnlock()
	if db == nil {
		return errors.New("database not open")
	}
	if it.ID == 0 {
		return errors.New("missing id for update")
	}
	return db.Save(&it).Error
}

// GetLastN — последние N элементов
func (d *DB) GetLastN(n int) ([]Item, error) {
	d.mu.RLock()
	db := d.db
	d.mu.RUnlock()
	if db == nil {
		return nil, errors.New("database not open")
	}
	var items []Item
	if err := db.Order("id DESC").Limit(n).Find(&items).Error; err != nil {
		return nil, err
	}
	return items, nil
}

// SearchLike — поиск LIKE
func (d *DB) SearchLike(field, value string, limit int) ([]Item, error) {
	d.mu.RLock()
	db := d.db
	d.mu.RUnlock()
	if db == nil {
		return nil, errors.New("database not open")
	}
	col, ok := allowedFields[field]
	if !ok {
		return nil, fmt.Errorf("unsupported field: %s", field)
	}
	var items []Item
	if err := db.Limit(limit).Order("id DESC").
		Where(fmt.Sprintf("%s LIKE ?", col), "%"+value+"%").
		Find(&items).Error; err != nil {
		return nil, err
	}
	return items, nil
}

// SearchExact — поиск по точному совпадению
func (d *DB) SearchExact(field, value string, limit int) ([]Item, error) {
	d.mu.RLock()
	db := d.db
	d.mu.RUnlock()
	if db == nil {
		return nil, errors.New("database not open")
	}
	col, ok := allowedFields[field]
	if !ok {
		return nil, fmt.Errorf("unsupported field: %s", field)
	}
	var items []Item
	if err := db.Limit(limit).Order("id DESC").
		Where(fmt.Sprintf("%s = ?", col), value).
		Find(&items).Error; err != nil {
		return nil, err
	}
	return items, nil
}

// ToJSON — сериализация
func ToJSON(v interface{}) (string, error) {
	b, err := json.Marshal(v)
	if err != nil {
		return "", err
	}
	return string(b), nil
}
