package reg

import "fmt"

type Reg struct {
	data map[string]float64
}

var regMe = Reg{
	data: make(map[string]float64),
}

// Init initializes and returns a pointer to the regMe instance of Reg.
// It can be used to obtain a reference to the singleton or shared Reg object.
func (r *Reg) Init() *Reg {
	return &regMe
}

// Set assigns the specified value to the given key in the Reg instance.
// If the operation fails, it returns an error.
func (r *Reg) Set(key string, value float64) error {
	r.data[key] = value
	return nil
}

// Get retrieves the value associated with the specified key from the registry.
// It returns the value as a string and an error if the key does not exist or retrieval fails.
func (r *Reg) Get(key string) (float64, error) {
	value, ok := r.data[key]
	if !ok {
		return value, fmt.Errorf("%s key not found", key)
	}
	return value, nil
}

// GetAll returns a slice containing all keys present in the Reg's data map.
func (r *Reg) GetAll() []string {
	var keys []string
	for k := range r.data {
		keys = append(keys, k)
	}
	return keys
}
