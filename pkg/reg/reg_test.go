package reg_test

import (
	"reflect"
	"testing"

	"github.com/pioruner/database/pkg/reg"
)

func TestReg_Init(t *testing.T) {
	tests := []struct {
		name string // description of this test case
		want *reg.Reg
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// TODO: construct the receiver type.
			var r reg.Reg
			got := r.Init()
			// TODO: update the condition below to compare got with tt.want.
			if true {
				t.Errorf("Init() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestReg_Set(t *testing.T) {
	tests := []struct {
		name string // description of this test case
		// Named input parameters for target function.
		key   string
		value float64
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// TODO: construct the receiver type.
			var r reg.Reg
			r.Set(tt.key, tt.value)
		})
	}
}

func TestReg_Get(t *testing.T) {
	tests := []struct {
		name string // description of this test case
		// Named input parameters for target function.
		key  string
		want string
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// TODO: construct the receiver type.
			var r reg.Reg
			got, _ := r.Get(tt.key)
			// TODO: update the condition below to compare got with tt.want.
			if true {
				t.Errorf("Get() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestReg_GetAll(t *testing.T) {
	type fields struct {
		data map[string]float64
	}
	tests := []struct {
		name   string
		fields fields
		want   []string
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := &reg.Reg{}
			for k, v := range tt.fields.data {
				r.Set(k, v)
			}
			if got := r.GetAll(); !reflect.DeepEqual(got, tt.want) {
				t.Errorf("Reg.GetAll() = %v, want %v", got, tt.want)
			}
		})
	}
}
