//autogenerated:yes
//nolint:golint,lll
package std_srvs

import (
	"github.com/aler9/goroslib/pkg/msg"
)

type EmptyReq struct {
	msg.Package `ros:"std_srvs"`
}

type EmptyRes struct {
	msg.Package `ros:"std_srvs"`
}

type Empty struct {
	msg.Package `ros:"std_srvs"`
	EmptyReq
	EmptyRes
}
