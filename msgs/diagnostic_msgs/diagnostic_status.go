// Autogenerated with msg-import, do not edit.
package diagnostic_msgs

import (
	"github.com/aler9/goroslib/msgs"
)

type DiagnosticStatus struct {
	msgs.Package `ros:"diagnostic_msgs"`
	Level        int8 `ros:"byte"`
	Name         string
	Message      string
	HardwareId   string
	Values       []KeyValue
}
