package cy

import (
	"context"
	"os/exec"

	"github.com/cfoust/cy/pkg/geom"
)

func NewTestServer() (*Cy, func(geom.Size) (*Client, error), error) {
	shell, err := exec.LookPath("bash")
	if err != nil {
		return nil, nil, err
	}

	ctx := context.Background()
	cy, err := Start(ctx, Options{
		Shell:     shell,
		SkipInput: true,
		StateDir:  "",
	})
	if err != nil {
		return nil, nil, err
	}

	// Nothing is reading from the client, so this will fail otherwise
	cy.defaultParams.SetUseSystemClipboard(true)

	return cy, func(size geom.Size) (*Client, error) {
		return cy.NewClient(ctx, ClientOptions{
			Env: map[string]string{
				"TERM": "xterm-256color",
			},
			Size: geom.DEFAULT_SIZE,
		})
	}, nil
}
