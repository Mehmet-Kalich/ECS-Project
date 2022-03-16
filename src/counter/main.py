
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
#get counter function.
@app.route("/")
def home():
    return 'healthy'

#Flask routes set-counter and sets up function which takes the view-count database from dynamodb and increments it.
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

#Get counter option simply returns the view-count item table as seen in both dynamo DB table + html 
#and returns a http ok 200 code. 
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
#Using flask, the local port is configured with this main.py file
if __name__ == '__main__':
    app.run(port=8080)
