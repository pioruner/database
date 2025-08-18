package transfer

type Item struct {
	ID     uint   `gorm:"primaryKey" json:"id" ru:"id"`
	Name   string `json:"name" ru:"Имя"`
	Number string `json:"number" ru:"Номер"`
}
