# Transformation of YAML Prometheus configuration files

## Motivation

Prometheus YAML configuration files contain a lot of repeated content, for example `relabel_config`
sections. This is fine when a program is generating the scripts but hard to maintain and error prone
when handled manually.

Basic text templating doesn't handle YAML syntax and structure well.

Two tools were considered:

* `yq` - a wrapper over `jq`, selected
* `ytt` - a native YAML text transformer, however hard to use and understand

## Overall design

The `transform.jq` code takes a top-level `++templates` entry to control its behaviour. It then does
exactly two things:

1. Remove the `++templates` section
2. Recursively transform the document looking for marker objects and using them to transform the content

Note that at present it does not allow multiple mutations on the same content.

## Example

```yaml
++templates:
  list-segments:
    name:
    - entries

any_element:
  any_nesting:
    any_list:
    - optional_precursor_elements
    - ++template-placeholder-list-segment: "name" # Inject elements here
    - optional_successors
```

## Directives

* `++template-placeholder-list-segment`:
    > Inject a named template list into the existing list at the same
    > nesting level as this element.