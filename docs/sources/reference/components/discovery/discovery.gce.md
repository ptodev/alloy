---
canonical: https://grafana.com/docs/alloy/latest/reference/components/discovery/discovery.gce/
aliases:
  - ../discovery.gce/ # /docs/alloy/latest/reference/components/discovery.gce/
description: Learn about discovery.gce
labels:
  stage: general-availability
  products:
    - oss
title: discovery.gce
---

# `discovery.gce`

`discovery.gce` allows you to retrieve scrape targets from [Google Compute Engine][] (GCE) instances.
The private IP address is used by default, but may be changed to the public IP address with relabeling.

Credentials are discovered by the Google Cloud SDK default client by looking in the following places, preferring the first location found:

1. A JSON file specified by the `GOOGLE_APPLICATION_CREDENTIALS` environment variable.
2. A JSON file in the well-known path `$HOME/.config/gcloud/application_default_credentials.json`.
3. Fetched from the GCE metadata server.

If {{< param "PRODUCT_NAME" >}} is running within GCE, the service account associated with the instance it's running on should have at least read-only permissions to the compute resources.
If running outside of GCE make sure to create an appropriate service account and place the credential file in one of the expected locations.

[Google Compute Engine]: https://cloud.google.com/compute

## Usage

```alloy
discovery.gce "<LABEL>" {
  project = "<PROJECT_NAME>"
  zone    = "<ZONE_NAME>"
}
```

## Arguments

You can use the following arguments with `discovery.gce`:

| Name               | Type       | Description                                                                                                             | Default | Required |
| ------------------ | ---------- | ----------------------------------------------------------------------------------------------------------------------- | ------- | -------- |
| `project`          | `string`   | The Google Cloud Platform Project.                                                                                      |         | yes      |
| `zone`             | `string`   | The zone of the scrape targets.                                                                                         |         | yes      |
| `filter`           | `string`   | Filter can be used optionally to filter the instance list by other criteria.                                            |         | no       |
| `port`             | `int`      | The port to scrape metrics from. If using the public IP address, this must instead be specified in the relabeling rule. | `80`    | no       |
| `refresh_interval` | `duration` | Refresh interval to re-read the instance list.                                                                          | `"60s"` | no       |
| `tag_separator`    | `string`   | The tag separator is used to separate the tags on concatenation.                                                        | `","`   | no       |

For more information on the syntax of the `filter` argument, refer to Google's `filter` documentation for [Method: instances.list][].

[Method: instances.list]: https://cloud.google.com/compute/docs/reference/latest/instances/list

## Blocks

The `discovery.gce` component doesn't support any blocks. You can configure this component with arguments.

## Exported fields

The following fields are exported and can be referenced by other components:

| Name      | Type                | Description                        |
| --------- | ------------------- | ---------------------------------- |
| `targets` | `list(map(string))` | The set of discovered GCE targets. |

Each target includes the following labels:

* `__meta_gce_instance_id`: The numeric ID of the instance.
* `__meta_gce_instance_name`: The name of the instance.
* `__meta_gce_interface_ipv4_NAME`: The IPv4 address of each named interface.
* `__meta_gce_label_LABEL_NAME`: Each GCE label of the instance.
* `__meta_gce_machine_type`: The full or partial URL of the machine type of the instance.
* `__meta_gce_metadata_NAME`: Each metadata item of the instance.
* `__meta_gce_network`: The network URL of the instance.
* `__meta_gce_private_ip`: The private IP address of the instance.
* `__meta_gce_project`: The GCP project in which the instance is running.
* `__meta_gce_public_ip`: The public IP address of the instance, if present.
* `__meta_gce_subnetwork`: The subnetwork URL of the instance.
* `__meta_gce_tags`: A comma separated list of instance tags.
* `__meta_gce_zone`: The GCE zone URL in which the instance is running.

## Component health

`discovery.gce` is only reported as unhealthy when given an invalid configuration.
In those cases, exported fields retain their last healthy values.

## Debug information

`discovery.gce` doesn't expose any component-specific debug information.

## Debug metrics

`discovery.gce` doesn't expose any component-specific debug metrics.

## Example

```alloy
discovery.gce "gce" {
  project = "alloy"
  zone    = "us-east1-a"
}

prometheus.scrape "demo" {
  targets    = discovery.gce.gce.targets
  forward_to = [prometheus.remote_write.demo.receiver]
}

prometheus.remote_write "demo" {
  endpoint {
    url = "<PROMETHEUS_REMOTE_WRITE_URL>"

    basic_auth {
      username = "<USERNAME>"
      password = "<PASSWORD>"
    }
  }
}
```

Replace the following:

* _`<PROMETHEUS_REMOTE_WRITE_URL>`_: The URL of the Prometheus remote_write-compatible server to send metrics to.
* _`<USERNAME>`_: The username to use for authentication to the `remote_write` API.
* _`<PASSWORD>`_: The password to use for authentication to the `remote_write` API.

<!-- START GENERATED COMPATIBLE COMPONENTS -->

## Compatible components

`discovery.gce` has exports that can be consumed by the following components:

- Components that consume [Targets](../../../compatibility/#targets-consumers)

{{< admonition type="note" >}}
Connecting some components may not be sensible or components may require further configuration to make the connection work correctly.
Refer to the linked documentation for more details.
{{< /admonition >}}

<!-- END GENERATED COMPATIBLE COMPONENTS -->
