package msgproc

import (
	"fmt"
	"reflect"

	rmsg "github.com/aler9/goroslib/pkg/msg"
)

// Type returns the type of a message.
func Type(msg interface{}) (string, error) {	
	msgt := reflect.TypeOf(msg)
	return TypeFromReflect(msgt)
}

// TypeFromReflect returns the type of a message based on a reflected type.
func TypeFromReflect(msgt reflect.Type) (string, error) {
	if msgt.Kind() != reflect.Struct {
		return "", fmt.Errorf("message must be a struct")
	}

	return typ(msgt), nil
}

func typ(msgt reflect.Type) string {
	name := msgt.Name()
	if name == "" {
		name = "Msg"
	}

	pkg := func() string {
		ft, ok := msgt.FieldByName("Package")
		if !ok || !ft.Anonymous || ft.Type != reflect.TypeOf(rmsg.Package(0)) {
			return ""
		}

		return ft.Tag.Get("ros")
	}()
	if pkg == "" {
		pkg = "goroslib"
	}

	return pkg + "/" + name
}
