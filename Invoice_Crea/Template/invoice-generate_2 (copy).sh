#! /bin/bash

# Get the direcotry of the script
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"



FILE_NAME=Invoice_Crea_$(date +"%Y-%m-%d_%T").fods
CONFIG_FILE=$SCRIPT_DIR/.config
INVOICE_DIR=$SCRIPT_DIR/../Crea_$(date +"%Y")
INVOICE_FILE=$INVOICE_DIR/$FILE_NAME
TEMPLATE_FILE=$SCRIPT_DIR/Invoice_Crea_template.fods



if ! [ -f "$CONFIG_FILE" ]; then
    echo "Config file $CONFIG_FILE doesnt exist. Please check that it exist in the same directory as the script: $SCRIPT_DIR"
    exit 1
fi


INVOICE_NUMBER=$(head -n 1 $CONFIG_FILE)

echo "Invoice number: $INVOICE_NUMBER"

while [ -z $INVOICE_NUMBER]; do
    echo
    echo "Error, config file %CONFIG_FILE is empty. "
    echo "Enter the number to use"
    read NEW_NUMBER
    echo $NEW_NUMBER > $CONFIG_FILE
    INVOICE_NUMBER=$(head -n 1 $CONFIG_FILE)
done

echo Copying invoice to $INVOICE_FILE
mkdir -p $INVOICE_DIR
cp $TEMPLATE_FILE $INVOICE_FILE



echo Modifying invoice $INVOICE_FILE

echo "Enter amount in EUR: "
read AMOUNT

echo
echo "This is invoice number $INVOICE_NUMBER"
echo "Press enter to continue or insert other number"
read NUMBER

if [ -z $NUMBER ]; then
    INVOICE_NUMBER=$NUMBER
fi



sed -i "s/123456789/$AMOUNT/g" $INVOICE_FILE
sed -i "s/987654321/$INVOICE_NUMBER/g" $INVOICE_FILE



let "INVOICE_NUMBER++"

# Save number to file
echo $INVOICE_NUMBER > $CONFIG_FILE

soffice --convert-to pdf $INVOICE_FILE --outdir $INVOICE_DIR --headless




