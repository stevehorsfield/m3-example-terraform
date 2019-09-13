# Capture templates from source file
."++templates" as $templates
# Templates are removed so that they don't get emitted in the result
| del(."++templates")
|
# Define helper functions
def get_list_segment_template:
  . as $__template
  | $templates
  | ."list-segments"
  | to_entries
  | map(select(.key == $__template) | .value)
;
# Define transformation logic
# Note: because the functions refer back to the main entry 'transform', these must be declared
#       as a single unit
def transform:
  # Transforms an indivual array entry
  # Input: single array entry
  # Output: array of array entries (possibly none) to allow for additional and removal as well as mapping
  def transform_array_entries:
    if (. | type) == "object" then
      if . | has("++template-placeholder-list-segment") then
        ."++template-placeholder-list-segment"
        | get_list_segment_template
        | .[0]
      else
        [ . ]
      end
    else
      [ . ]
    end
  ;
  # Recursively transform a whole array
  # Input: single array
  # Output: single transfomed array
  def transform_array:
    .
    | map(transform_array_entries)
    | flatten(1)
    | map(transform)
  ;
  # Transforms an indivual object field
  # Input: single object field K/V (from to_entries)
  # Output: array of object fields (possibly none) to allow for additional and removal as well as mapping
  def transform_object_keys:
    [ . ]
  ;
  # Recursively transform a whole object
  # Input: single object
  # Output: single transfomed object
  def transform_object:
    .
    | to_entries
    | map(transform_object_keys)
    | flatten(1)
    | map(.value |= transform)
    | from_entries
  ;
  # Recursively transform the current item
  if (. | type) == "object" then
    transform_object
  elif (. | type) == "array" then
    transform_array
  elif (. | type) == "string" then
    .
  else
    .
  end
;
# Execute the transformation
. | transform