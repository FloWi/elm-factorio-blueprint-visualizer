IFS=$'\n' # IFS = internal field separator

BASE64_CONTENT=$(cat blueprint-book.txt)
BOOK=$(echo $BASE64_CONTENT | sed '1s/^.//' | base64 --decode | pigz -dc)

for label in $(echo $BOOK | jq -r ".blueprint_book.blueprints[].blueprint.label"); do
    FILENAME_JSON="balancers/$label.json"
    FILENAME_BASE64="balancers/$label.txt"

    balancer=$(echo $BOOK | jq ".blueprint_book.blueprints[] | select(.blueprint.label == \"$label\") | .index=0")
    new_book=$(echo $BOOK | jq -c ". | .blueprint_book.blueprints = [$balancer]")
    encoded=$(echo "0$(echo $new_book | pigz -9z | base64)")

    echo $new_book | jq "." >$FILENAME_JSON
    echo $encoded >$FILENAME_BASE64
    echo "wrote books for '$label'"
done
