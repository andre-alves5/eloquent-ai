package test

import (
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAlbModule(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	terraformDir, err := filepath.Abs("./alb")
	if err != nil {
		t.Fatal(err)
	}

	opts := &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"tags": map[string]string{
				"TestRun": uniqueID,
			},
		},
		MaxRetries:         4,
		TimeBetweenRetries: 10 * time.Second,
	}

	defer terraform.Destroy(t, opts)

	terraform.InitAndApply(t, opts)

	albDNS := terraform.Output(t, opts, "alb_dns")
	albArn := terraform.Output(t, opts, "alb_arn")
	albSG := terraform.Output(t, opts, "alb_sg")

	assert.NotEmpty(t, albDNS, "alb_dns should not be empty")
	assert.NotEmpty(t, albArn, "alb_arn should not be empty")
	assert.NotEmpty(t, albSG, "alb_sg should not be empty")

	assert.True(t, strings.Contains(albDNS, "."), "alb_dns should look like a DNS name")
}
