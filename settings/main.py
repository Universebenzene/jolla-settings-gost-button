#!/usr/bin/env python
# -*- coding: utf-8 -*-
'''
Created on 2017年11月29日

@author: BirdZhang
'''
import json
import os

HOME = os.path.expanduser("~")
XDG_CONFIG_HOME = os.environ.get("XDG_CONFIG_HOME", os.path.join(HOME, ".config"))
gost_conf = os.path.join(XDG_CONFIG_HOME, "gost/gost.json")
sample_configs = """{
    "Debug": true,
    "Retries": 3,
    "ServeNodes": [
       "socks://127.0.0.1:10080"
    ],
    "ChainNodes": [
       "ss://aes-256-cfb:password@192.168.2.1:2379"
    ]
}"""



def writeConfig(config):
    with open(gost_conf, "w") as f:
        f.write(config)

def readConfig():
    with open(gost_conf, "r") as f:
        lines = f.readlines()
        return "".join(lines)

def getSS():
    try:
        config_str = readConfig()
        config_map = json.loads(config_str)
        return config_map.get("ChainNodes")[0]
    except:
        return None

def update( server, port, passwd, encryption):
    chain_server = "ss://%s:%s@%s:%s" % (encryption, passwd, server, port)
    if os.path.exists(gost_conf):
        config_str = readConfig()
        config_map = json.loads(config_str)
        config_map["ChainNodes"][0] = chain_server
        writeConfig(json.dumps(config_map,indent=4))
    else:
        config_map = json.loads(sample_configs)
        config_map["ChainNodes"][0] = chain_server
        writeConfig(json.dumps(config_map,indent=4))



