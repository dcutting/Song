# Lexie's substitution cipher

c.toNumber = c.scalar - 96
n.toLetter = (n + 96).character

n.cipher = n + 5
n.decipher = n - 5

s.endecode(f) = s.map(|c| c.toNumber).map(f).map(|n| n.toLetter)

s.encode = s.endecode(cipher)
s.decode = s.endecode(decipher)

my_message = "i am the GOAT!".encode
my_message.decode
