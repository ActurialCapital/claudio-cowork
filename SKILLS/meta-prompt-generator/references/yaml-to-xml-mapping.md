# YAML-to-XML Schema Mapping Reference

Read this when the user requests XML schema output from a spec.

## Direct Mapping Rules

### Scalars
```yaml
objective: "Build a REST API"
```
```xml
<objective>Build a REST API</objective>
```

### Lists → Repeated Elements
```yaml
constraints:
  technical:
    - "Python 3.11+"
    - "FastAPI framework"
```
```xml
<constraints>
  <technical>
    <item>Python 3.11+</item>
    <item>FastAPI framework</item>
  </technical>
</constraints>
```

### Typed Inputs → xs:complexType
```yaml
inputs:
  - name: "trade_data"
    type: "dataset"
    format: "csv"
    required: true
    schema: "columns: [timestamp, symbol, price, quantity, side]"
```
```xml
<xs:element name="trade_data" minOccurs="1">
  <xs:complexType>
    <xs:sequence>
      <xs:element name="type" type="xs:string" fixed="dataset"/>
      <xs:element name="format" type="xs:string" fixed="csv"/>
      <xs:element name="schema">
        <xs:complexType>
          <xs:sequence>
            <xs:element name="column" maxOccurs="unbounded">
              <xs:simpleType>
                <xs:restriction base="xs:string">
                  <xs:enumeration value="timestamp"/>
                  <xs:enumeration value="symbol"/>
                  <xs:enumeration value="price"/>
                  <xs:enumeration value="quantity"/>
                  <xs:enumeration value="side"/>
                </xs:restriction>
              </xs:simpleType>
            </xs:element>
          </xs:sequence>
        </xs:complexType>
      </xs:element>
    </xs:sequence>
  </xs:complexType>
</xs:element>
```

### Workflow Steps → xs:sequence with Dependencies
```yaml
workflow:
  type: "sequential"
  steps:
    - id: "fetch"
      action: "Pull data from API"
      depends_on: []
    - id: "transform"
      action: "Clean and normalize"
      depends_on: ["fetch"]
```
```xml
<workflow type="sequential">
  <xs:sequence>
    <step id="fetch">
      <action>Pull data from API</action>
      <depends_on/>
    </step>
    <step id="transform">
      <action>Clean and normalize</action>
      <depends_on>
        <ref>fetch</ref>
      </depends_on>
    </step>
  </xs:sequence>
</workflow>
```

### Conditional Workflows → xs:choice
```yaml
workflow:
  type: "conditional"
  steps:
    - id: "check_size"
      action: "Count rows"
      output: "row_count"
    - id: "small_path"
      action: "Process in memory"
      condition: "row_count < 1M"
    - id: "large_path"
      action: "Use Spark"
      condition: "row_count >= 1M"
```
```xml
<workflow type="conditional">
  <step id="check_size">
    <action>Count rows</action>
    <output>row_count</output>
  </step>
  <xs:choice>
    <step id="small_path" condition="row_count &lt; 1000000">
      <action>Process in memory</action>
    </step>
    <step id="large_path" condition="row_count &gt;= 1000000">
      <action>Use Spark</action>
    </step>
  </xs:choice>
</workflow>
```

### Validation → Schematron Assertions
```yaml
outputs:
  - name: "backtest_report"
    validation: "Sharpe ratio field exists and is numeric; max_drawdown is negative; total_return matches sum of daily returns within 0.01%"
```
```xml
<sch:rule context="backtest_report">
  <sch:assert test="number(sharpe_ratio) = sharpe_ratio">
    Sharpe ratio must be numeric
  </sch:assert>
  <sch:assert test="max_drawdown &lt; 0">
    Max drawdown must be negative
  </sch:assert>
  <sch:assert test="abs(total_return - sum(daily_returns)) &lt; 0.0001">
    Total return must match sum of daily returns within 0.01%
  </sch:assert>
</sch:rule>
```

## Multi-Agent Specs
For orchestrated specs, each agent becomes a nested complexType:

```xml
<agents>
  <agent role="data_collector">
    <objective>Fetch and normalize market data</objective>
    <inputs><ref>raw_feeds</ref></inputs>
    <outputs><ref>clean_dataset</ref></outputs>
    <handoff_to><ref>analyst</ref></handoff_to>
  </agent>
  <agent role="analyst">
    <objective>Run statistical analysis</objective>
    <inputs><ref>clean_dataset</ref></inputs>
    <outputs><ref>analysis_report</ref></outputs>
  </agent>
</agents>
```
