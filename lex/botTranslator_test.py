#!/usr/bin/python
# coding=utf-8
import unittest
import json
import boto3
import random
from botTranslator import translateBot

'''
To run test: python3 -m unittest botTranslator_test
'''
class botTranslator_test(unittest.TestCase):


    def setUp(self):
        pass

    # Test Chinese (Simplified) bot
    def test_rose_zh(self):
        userid = "user" + str(random.randint(1,9999)).zfill(4)

        local_message = "我想订花" # I want to order flowers.
        botResponse = translateBot(local_message=local_message, userid=userid)
        assert botResponse["en_response"] == "What type of flowers would you like to order?"

        local_message = "玫瑰花" # Roses
        botResponse = translateBot(local_message=local_message, userid=userid)
        assert "What day do you want" in botResponse["en_response"] 

        local_message = "星期五" # Friday
        botResponse = translateBot(local_message=local_message, userid=userid)
        assert "what time" in botResponse["en_response"] 

        local_message = "早晨九点" # 9 o'clock in the morning.
        botResponse = translateBot(local_message=local_message, userid=userid)
        assert "Does this sound okay" in botResponse["en_response"]

        local_message = "好的" # Okay
        botResponse = translateBot(local_message=local_message, userid=userid)
        assert botResponse["confirmation"]["slots"]["FlowerType"] == "Roses"

    # Test Indonesian bot
    def test_rose_id(self):
        userid = "user" + str(random.randint(1,9999)).zfill(4)

        local_message = "Aku ingin memesan bunga" # I want to order flowers.
        botResponse = translateBot(local_message=local_message, userid=userid)
        assert botResponse["en_response"] == "What type of flowers would you like to order?"

        local_message = "mawar" # Roses
        botResponse = translateBot(local_message=local_message, userid=userid)
        assert "What day do you want" in botResponse["en_response"] 

        local_message = "Jumat" # Friday
        botResponse = translateBot(local_message=local_message, userid=userid)
        assert "what time" in botResponse["en_response"] 

        local_message = "Pukul 9 pagi" # 9 o'clock in the morning.
        botResponse = translateBot(local_message=local_message, userid=userid)
        assert "Does this sound okay" in botResponse["en_response"]

        local_message = "Oke. Oke" # Okay
        botResponse = translateBot(local_message=local_message, userid=userid)
        assert botResponse["confirmation"]["slots"]["FlowerType"].lower() == "Roses".lower()
