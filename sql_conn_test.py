import sqlite3

conn = sqlite3.connect(":memory:")
conn.enable_load_extension(True)
print("SQLite extension loading is supported.")
