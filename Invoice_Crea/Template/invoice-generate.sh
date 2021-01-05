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
INVOICE_XML=$INVOICE_DIR/../Sources/$FILE_NAME
INVOICE_FILE=$INVOICE_DIR/$FILE_NAME
INVOICE_PDF="${INVOICE_FILE%.*}.pdf"

TEMPLATE_FILE=$SCRIPT_DIR/Invoice_Crea_template.fods

echo "Config file: $CONFIG_FILE"


if ! git pull; 
then
    echo
    echo "Error pulling from git. Make sure everything is working right."
    echo "Press any key to continue or Ctrl-C to exit"
    read
fi



if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file $CONFIG_FILE doesnt exist. Please check that it exist in the same directory as the script: $SCRIPT_DIR"
    exit 1
fi

YEAR=$(date +%Y)
INVOICE_NUMBER=$(head -n 1 $CONFIG_FILE)
INVOICE_ID="$(date +%Y)-$INVOICE_NUMBER"

echo "Invoice number: $INVOICE_NUMBER"
echo "Invoice id: $INVOICE_ID"

while [ -z $INVOICE_NUMBER ]; do
    echo
    echo "Error, config file %CONFIG_FILE is empty. "
    echo "Enter the number to use"
    read NEW_NUMBER
    echo $NEW_NUMBER > $CONFIG_FILE
    INVOICE_NUMBER=$(head -n 1 $CONFIG_FILE)
done


echo Modifying invoice $INVOICE_XML

echo "Enter amount in EUR: "
read AMOUNT

echo
echo "This is invoice number $INVOICE_NUMBER"
echo "Press enter to continue or insert other number"
read NUMBER


if [ ! -z $NUMBER ]; then
    INVOICE_NUMBER=$NUMBER
    INVOICE_ID="$(date +%Y)-$INVOICE_NUMBER"
    echo "Invoice id: $INVOICE_ID"
fi


echo Copying invoice to $INVOICE_XML
mkdir -p $INVOICE_DIR
cp $TEMPLATE_FILE $INVOICE_XML

echo "Invoice amount: $AMOUNT"
echo "Invoice id: $INVOICE_ID"

sed -i "s/123456789/$AMOUNT/g" $INVOICE_XML
sed -i "s/9876_54321/$INVOICE_ID/g" $INVOICE_XML


echo before: $INVOICE_NUMBER


INVOICE_NUMBER=$((INVOICE_NUMBER+1))

echo now: $INVOICE_NUMBER



# Save number to file
echo $INVOICE_NUMBER > $CONFIG_FILE


echo pdf name: $INVOICE_PDF

soffice --convert-to pdf $INVOICE_XML --outdir $INVOICE_DIR --headless

echo
echo "Submitting to GIT. Press any key to continue..."
read 
git add .
git commit -am "Invoice $INVOICE_NUMBER $INVOICE_ID"
git push

xdg-open $INVOICE_PDF




