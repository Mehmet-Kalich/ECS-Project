
#Packages imported
import json, boto3
from botocore.config import Config
from flask import Flask
my_config = Config(
    region_name = 'us-east-1'
)
#database table (in dynamoDB) and region are specified
app = Flask(__name__)
client = boto3.client('dynamodb', config=my_config)
TableName = 'cloud-resume'

#Flask routes application to root-url, as well as the set-counter (increment) function
#get counter function
@app.route("/")
def home():
    return 'healthy'

@app.route("/set-counter")
def set_counter():
     
    response = client.update_item(
        TableName='cloud-resume',
        Key = {
            'stat': {'S': 'view-count'}
        },
        UpdateExpression = 'ADD Quantity :inc',
        ExpressionAttributeValues = {":inc" : {"N": "1"}},
        ReturnValues = 'UPDATED_NEW'
        )
        
    value = response['Attributes']['Quantity']['N']
    
    return {
            'statusCode': 200,
            'body': value,
            "headers": 
            {
            "Access-Control-Allow-Origin" : "*"
            }
        }

@app.route("/get-counter")
def get_counter():
    data = client.get_item(
        TableName='cloud-resume',
        Key = {
            'stat': {'S': 'view-count'}
        }
    )
    prevViewCount = data['Item']['Quantity']['N']
    
    return {
            'statusCode': 200,
            'body': data,
            "headers": 
            {
            "Access-Control-Allow-Origin" : "*"
            }
        }
if __name__ == '__main__':
    app.run(port=8080)
