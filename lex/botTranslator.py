#!/usr/bin/python
# coding=utf-8

import json
import boto3
import random
import logging

BOT_NAME = "OrderFlowers"
BOT_ALIAS = "LATEST"

def translateBot(local_message, userid):
	"""
	Calls the Lex bot, with bidirectional translation to/from the language of the message. 
	"""
	print("translating local_message: " + local_message)
	comprehend = boto3.client(service_name='comprehend', region_name='us-east-1')
	language = comprehend.detect_dominant_language(Text=local_message)["Languages"][0]["LanguageCode"]
	
	translate = boto3.client(service_name='translate', region_name='us-east-1')
	translated_message = translate.translate_text(Text=local_message, SourceLanguageCode=language, TargetLanguageCode="en")
	lex = boto3.client(service_name='lex-runtime', region_name='us-east-1')
	en_response = lex.post_text(botName=BOT_NAME, botAlias=BOT_ALIAS, userId=userid, inputText=translated_message['TranslatedText'])

	# check presence of "message" field to see if there is a dialog or if its the final confirmation. 
	if "message" in en_response:
		en_response = en_response.get("message")
		local_response = translate.translate_text(Text=en_response, SourceLanguageCode="en", TargetLanguageCode=language).get('TranslatedText')
		return {
			"local_message": local_message,
			"en_message": translated_message['TranslatedText'],
			"en_response": en_response,
			"local_response": local_response,
			"local_language": language
		}
	else:
		return { 
			"confirmation": en_response 
		}

def lambda_handler(event, context):
    botResponse = translateBot( intent=event["intent"], userid=event["userid"] )
    return {
        "statusCode": 200,
        "body": botResponse
    }

if __name__ == '__main__':
	pass

