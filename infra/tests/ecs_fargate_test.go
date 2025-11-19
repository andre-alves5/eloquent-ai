package test

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"path/filepath"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

type HealthResp struct {
	Status  string `json:"status"`
	Version string `json:"version"`
}

func TestEcsFargateModule(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	name := fmt.Sprintf("test-eloquent-%s", uniqueID)

	terraformDir, err := filepath.Abs("../modules/ecs-fargate/")
	if err != nil {
		t.Fatal(err)
	}

	tfOptions := &terraform.Options{
		TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"name":            name,
			"environment":     "terratest",
			"container_image": "public.ecr.aws/amazonlinux/amazonlinux:latest", // placeholder; ideally a tiny test image
			// If your module expects vpc/subnet inputs, pass test VPC IDs or include a test VPC module
			// Example for local quick test you might include a minimal VPC in the test folder
			// "vpc_id": "<TEST_VPC_ID>",
			// "public_subnets": []string{"subnet-..."},
			// "private_subnets": []string{"subnet-..."},
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	}

	defer terraform.Destroy(t, tfOptions)

	terraform.InitAndApply(t, tfOptions)

	albDNS := terraform.Output(t, tfOptions, "alb_dns")
	assert.NotEmpty(t, albDNS, "alb_dns output should not be empty")

	url := fmt.Sprintf("http://%s/health", albDNS)

	description := fmt.Sprintf("Checking ALB health endpoint %s", url)
	maxRetries := 20
	sleepBetween := 15 * time.Second

	httpCheck := func() (string, error) {
		resp, err := http.Get(url)
		if err != nil {
			return "", err
		}
		defer resp.Body.Close()

		if resp.StatusCode < 200 || resp.StatusCode > 399 {
			return "", fmt.Errorf("unexpected status code: %d", resp.StatusCode)
		}

		body, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			return "", err
		}

		var hr HealthResp
		if err := json.Unmarshal(body, &hr); err != nil {
			return "", fmt.Errorf("invalid json: %v", err)
		}

		if hr.Status != "healthy" {
			return "", fmt.Errorf("service not healthy yet: %+v", hr)
		}

		return string(body), nil
	}

	out, err := retry.DoWithRetryE(t, description, maxRetries, sleepBetween, func() (string, error) {
		return httpCheck()
	})
	if err != nil {
		t.Fatalf("Health endpoint check failed: %v", err)
	}

	t.Logf("Health check response: %s", out)

	http_helper.HttpGetWithRetry(t, fmt.Sprintf("http://%s/api/hello", albDNS), nil, 200, 10, 10*time.Second)

	serviceName := terraform.Output(t, tfOptions, "service_name")
	assert.NotEmpty(t, serviceName)
}
