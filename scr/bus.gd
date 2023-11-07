# Idea credit: https://stackoverflow.com/a/68675270/18532845

extends Node

signal begin_connection(source: OutputConnector)
signal request_finish_connection(source: OutputConnector)
signal fail_connection()
signal successful_connection(from: OutputConnector, to: InputConnector)
signal destroyed_connection(from: OutputConnector, to: InputConnector)
# signal end_connect(target: InputConnector)

