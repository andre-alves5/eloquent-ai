package test

import (
	"net"
	"path/filepath"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestVpcModule(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	terraformDir, err := filepath.Abs("../modules/networking")
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
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	}

	defer terraform.Destroy(t, opts)

	terraform.InitAndApply(t, opts)

	vpcID := terraform.Output(t, opts, "vpc_id")
	publicSubnets := terraform.OutputList(t, opts, "public_subnets")
	privateSubnets := terraform.OutputList(t, opts, "private_subnets")

	assert.NotEmpty(t, vpcID, "vpc_id should be set")
	assert.GreaterOrEqual(t, len(publicSubnets), 1, "expect at least 1 public subnet")
	assert.GreaterOrEqual(t, len(privateSubnets), 1, "expect at least 1 private subnet")

	for _, cidr := range append(publicSubnets, privateSubnets...) {
		_, _, err := net.ParseCIDR(cidr)
		if err != nil {
			t.Logf("warning: unable to parse CIDR '%s': %v", cidr, err)
		}
	}
}
