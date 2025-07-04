---
canonical: https://grafana.com/docs/alloy/latest/release-notes/
description: Release notes for Grafana Alloy
menuTitle: Release notes
title: Release notes for Grafana Alloy
weight: 999
---

# Release notes for {{% param "FULL_PRODUCT_NAME" %}}

The release notes provide information about deprecations and breaking changes in {{< param "FULL_PRODUCT_NAME" >}}.

For a complete list of changes to {{< param "FULL_PRODUCT_NAME" >}}, with links to pull requests and related issues when available, refer to the [Changelog][].

[Changelog]: https://github.com/grafana/alloy/blob/main/CHANGELOG.md

## v1.9

### Breaking change: The `prometheus.exporter.oracledb` component now embeds a different exporter

The `prometheus.exporter.oracledb` component now embeds the [`oracledb_exporter from oracle`](https://github.com/oracle/oracle-db-appdev-monitoring) instead of the deprecated [`oracledb_exporter from iamseth`](https://github.com/iamseth/oracledb_exporter).

As a result of this change, the following metrics are no longer available by default:

- `oracledb_sessions_activity`
- `oracledb_tablespace_free_bytes`

The previously undocumented argument `custom_metrics` is now expecting a list of paths to custom metrics files.

### Breaking change: The `enable_context_propagation` argument in `beyla.ebpf` has been replaced with the `context_propagation` argument.

Set `enable_context_propagation` to `all` to get the same behaviour as `enable_context_propagation` being set to `true`.

### Breaking change: In `prometheus.exporter.windows`, the `service` and `msmq` collectors no longer work with WMI

The `msmq` block has been removed. The `enable_v2_collector`, `where_clause`, and `use_api` attributes in the `service` block are also removed.

Prior to Alloy v1.9.0, the `service` collector exists in 2 different versions. 
Version 1 used WMI (Windows Management Instrumentation) to query all services and was able to provide additional information. 
Version 2 is a more efficient solution by directly connecting to the service manager, 
but is not able to provide additional information like run_as or start configuration.

In Alloy v1.9.0 the Version 1 collector was removed, hence why some arguments and blocks were removed.
In Alloy v1.9.2 those arguments and blocks were re-introduced as a no-op in order to make migrations easier for customers.

Due to this change, the metrics produced by `service` collector are different in v1.9.0 and above.
The `msmq` collector metrics are unchanged.

Example V2 `service` metrics:

```
windows_service_state{display_name="Declared Configuration(DC) service",name="dcsvc",status="continue pending"} 0
windows_service_state{display_name="Declared Configuration(DC) service",name="dcsvc",status="pause pending"} 0
windows_service_state{display_name="Declared Configuration(DC) service",name="dcsvc",status="paused"} 0
windows_service_state{display_name="Declared Configuration(DC) service",name="dcsvc",status="running"} 0
windows_service_state{display_name="Declared Configuration(DC) service",name="dcsvc",status="start pending"} 0
windows_service_state{display_name="Declared Configuration(DC) service",name="dcsvc",status="stop pending"} 0
windows_service_state{display_name="Declared Configuration(DC) service",name="dcsvc",status="stopped"} 1
```

For more information on V1 and V2 `service` metrics, see the upstream exporter documentation for [version 0.27.3 of the Windows Exporter][win-exp-svc-0-27-3],
which is the version used in Alloy v1.8.3. 
Alloy v1.9.2 uses [version 0.30.7 of the Windows Exporter][win-exp-svc-0-27-3].

[win-exp-svc-0-27-3]: https://github.com/prometheus-community/windows_exporter/blob/v0.27.3/docs/collector.service.md
[win-exp-svc-0-30-7]: https://github.com/prometheus-community/windows_exporter/blob/v0.30.7/docs/collector.service.md

## v1.6

### Breaking change: The `topics` argument in the component `loki.source.kafka` does not use regex by default anymore

A bug in `loki.source.kafka` caused the component to treat all topics as regular expressions. For example, setting the topic value to "telemetry" would match any topic containing the substring "telemetry".
With the fix introduced in this version, topic values are now treated as exact matches by default.
Regular expression matching is still supported by prefixing a topic with "^", allowing it to match multiple topics.

### Breaking change: Change decision precedence in `otelcol.processor.tail_sampling` when using `and_sub_policy` and `invert_match` 

Alloy v1.5 upgraded to [OpenTelemetry Collector v0.104.0][otel-v0_104], which included a [fix][#33671] to the tail sampling processor:

> Previously if the decision from a policy evaluation was `NotSampled` or `InvertNotSampled` 
> it would return a `NotSampled` decision regardless, effectively downgrading the result.
> This was breaking the documented behaviour that inverted decisions should take precedence over all others.

The "documented behavior" which the above quote is referring to is in the [processor documentation][tail-sample-docs]:

> Each policy will result in a decision, and the processor will evaluate them to make a final decision:
> 
> * When there's an "inverted not sample" decision, the trace is not sampled;
> * When there's a "sample" decision, the trace is sampled;
> * When there's a "inverted sample" decision and no "not sample" decisions, the trace is sampled;
> * In all other cases, the trace is NOT sampled
> 
> An "inverted" decision is the one made based on the "invert_match" attribute, such as the one from the string, numeric or boolean tag policy.
    
However, in [OpenTelemetry Collector v0.116.0][otel-v0_116] this fix was [reverted][#36673]:

> Reverts [#33671][], allowing for composite policies to specify inverted clauses in conjunction with other policies. 
> This is a change bringing the previous state into place, breaking users who rely on what was introduced as part of [#33671][].

[otel-v0_104]: https://github.com/open-telemetry/opentelemetry-collector-contrib/releases/tag/v0.104.0
[otel-v0_116]: https://github.com/open-telemetry/opentelemetry-collector-contrib/releases/tag/v0.116.0
[#33671]: https://github.com/open-telemetry/opentelemetry-collector-contrib/pull/33671
[#33671]: https://github.com/open-telemetry/opentelemetry-collector-contrib/pull/33671
[#36673]: https://github.com/open-telemetry/opentelemetry-collector-contrib/pull/36673
[tail-sample-docs]: https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.116.0/processor/tailsamplingprocessor/README.md

## v1.5

### Breaking change: Change default value of `max_streams` in `otelcol.processor.deltatocumulative`

The default value was changed from `0` to `9223372036854775807` (max int).

### Breaking change: Change default value of `namespace` in `otelcol.connector.spanmetrics`

The default value was changed from `""` to `"traces.span.metrics"`.

### Breaking change: The component `otelcol.exporter.logging` has been removed in favor of `otelcol.exporter.debug`

Both components are very similar. More information can be found in the [announcement issue](https://github.com/open-telemetry/opentelemetry-collector/issues/11337).

### Breaking change: Change default value of `revision` in `import.git`

The default value was changed from `"HEAD"` to `"main"`.
Setting the `revision` to `"HEAD"`, `"FETCH_HEAD"`, `"ORIG_HEAD"`, `"MERGE_HEAD"` or `"CHERRY_PICK_HEAD"` is no longer allowed.

## v1.4

### Breaking change: Some debug metrics for `otelcol` components have changed

For example, `otelcol.exporter.otlp`'s `exporter_sent_spans_ratio_total` metric is now `otelcol_exporter_sent_spans_total`.
You may need to change your dashboard and alert settings to reference the new metrics.
Refer to each component's documentation page for more information.

### Breaking change: The `convert_sum_to_gauge` and `convert_gauge_to_sum` functions in `otelcol.processor.transform` change context

The `convert_sum_to_gauge` and `convert_gauge_to_sum` functions must now be used in the `metric` context rather than in the `datapoint` context.
This is due to a [change upstream](https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/34567).

### Breaking change: Renamed metrics in `beyla.ebpf`

`process.cpu.state` is renamed to `cpu.mode` and `beyla_build_info` is renamed to `beyla_internal_build_info`.

## v1.3

### Breaking change: `remotecfg` block updated argument name from `metadata` to `attributes`

{{< admonition type="note" >}}
This feature is in [Public preview][] and is not covered by {{< param "FULL_PRODUCT_NAME" >}} [backward compatibility][] guarantees.

[Public preview]: https://grafana.com/docs/release-life-cycle/
[backward compatibility]: ../introduction/backward-compatibility/
{{< /admonition >}}

The `remotecfg` block has an updated argument name from `metadata` to `attributes`.

## v1.2

### Breaking change: `remotecfg` block updated for Agent rename

{{< admonition type="note" >}}
This feature is in [Public preview][] and is not covered by {{< param "FULL_PRODUCT_NAME" >}} [backward compatibility][] guarantees.

[Public preview]: https://grafana.com/docs/release-life-cycle/
[backward compatibility]: ../introduction/backward-compatibility/
{{< /admonition >}}

The `remotecfg` block has been updated to use [alloy-remote-config](https://github.com/grafana/alloy-remote-config)
over [agent-remote-config](https://github.com/grafana/agent-remote-config). This change
aligns `remotecfg` API terminology with Alloy and includes updated endpoints.