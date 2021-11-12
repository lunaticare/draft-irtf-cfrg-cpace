import sys

def ByteArrayToInteger(k,numBytes=32):
    try:
        k_list = [ord(b) for b in k]
    except:
        k_list = [b for b in k]
 
    if numBytes < len(k_list):
    	numBytes = len(k_list)
    	
    return sum((k_list[i] << (8 * i)) for i in range(len(numBytes)))

def IntegerToByteArray(k,numBytes = 32):
    result = bytearray(numBytes);
    for i in range(numBytes):
        result[i] = (k >> (8 * i)) & 0xff;
    return result

def IntegerToLEPrintString(u,numBytes=32):
    u = Integer(u)
    res = ""
    ctr = 0
    while ((u != 0) | (numBytes > 0)):
        byte =  u % 256
        res += ("%02x" % byte)
        u = (u - byte) >> 8
        numBytes = numBytes - 1
        ctr = ctr + 1
    return res

def ByteArrayToCInitializer(k, name, values_per_line = 12):
    values = [b for b in k]
    result = "const uint8_t " + name +"[] = {"
    n = 0
    for x in values:
        if n == 0:
            result += "\n "
        n = (n + 1) % values_per_line;
        
        result += ("0x%02x" %x) +","
    result += "\n};"
    return result

def ByteArrayToLEPrintString(k):
    bytes = [(b) for b in k]
    res = ""
    ctr = 0
    for x in bytes:
        res += ("%02x" %x)
        ctr = ctr + 1
    return res

def tv_output_byte_array(data, test_vector_name = "", line_prefix = "  ", max_len = 60, file = sys.stdout):
    string = ByteArrayToLEPrintString(data)
    print (line_prefix + test_vector_name + ": (length: %i bytes)" % len(data) ,end="",file = file)
    chars_per_line = max_len - len(line_prefix)
    while True:
        print ("\n" + line_prefix + "  " + string[0:chars_per_line],end="", file = file)
        string = string[chars_per_line:-1]
        if len(string) == 0:
            print("\n",end="",file=file)
            return
            
def prepend_length_to_bytes(data):
    length_as_utf8_string = chr(len(data)).encode('utf-8')
    return length_as_utf8_string + data 

def prefix_free_cat(*args):
    result = b""
    for arg in args:
        result += prepend_length_to_bytes(arg)
    return result

def oCAT(str1,str2):
    if str1 > str2:
        return str1 + str2
    else:
        return str2 + str1

def zero_bytes(length):
    result = b"\0" * length
    return result

def generator_string(PRS,DSI,CI,sid,s_in_bytes):
    """
    Concat all input fields with prepended length information.
    Add zero padding in the first hash block between PRS and DSI.
    """
    len_zpad = max(0,s_in_bytes - 1 - len(prepend_length_to_bytes(PRS)))
    return (prefix_free_cat(PRS, zero_bytes(len_zpad), DSI, CI, sid), len_zpad)

    
def generate_testvectors_string_functions(file = sys.stdout):
    print ("\n## Definition and test vectors for string utility functions\n", file = file)
    print ("\n### prepend_length function\n", file = file)

    print (
"""
~~~
  def prepend_length_to_bytes(data):
      length_as_utf8_string = chr(len(data)).encode('utf-8')
      return (length_as_utf8_string + data)
~~~
""", file = file);

    print ("\n### prepend_length test vectors\n", file = file)
    print ("~~~", file = file)

    tv_output_byte_array(prepend_length_to_bytes(b""), 
                         test_vector_name = 'prepend_length_to_bytes(b"")', 
                         line_prefix = "  ", max_len = 60, file = file);
    tv_output_byte_array(prepend_length_to_bytes(b"1234"), 
                         test_vector_name = 'prepend_length_to_bytes(b"1234")', 
                         line_prefix = "  ", max_len = 60, file = file);

    tv_output_byte_array(prepend_length_to_bytes(bytes(range(127))), 
                         test_vector_name = 'prepend_length_to_bytes(bytes(range(127)))', 
                         line_prefix = "  ", max_len = 60, file = file);
    tv_output_byte_array(prepend_length_to_bytes(bytes(range(128))), 
                         test_vector_name = 'prepend_length_to_bytes(bytes(range(128)))', 
                         line_prefix = "  ", max_len = 60, file = file);

    print ("~~~", file = file)
    
    print ("\n### prefix_free_cat function\n", file = file)
    
    print (
"""
~~~
  def prefix_free_cat(*args):
      result = b""
      for arg in args:
          result += prepend_length_to_bytes(arg)
      return result
~~~
""", file = file);


    print ("\n### Testvector for prefix_free_cat()\n", file = file)
    print ("~~~", file = file)
    tv_output_byte_array(prefix_free_cat(b"1234",b"5",b"",b"6789"), 
                         test_vector_name = 'prefix_free_cat(b"1234",b"5",b"",b"6789")', 
                         line_prefix = "  ", max_len = 60, file = file);
    
    print ("~~~", file = file)
    
    print ("\n## Definitions and test vector ordered concatenation\n", file = file)

    print ("\n### Definitions ordered concatenation\n", file = file)

    print ("~~~", file = file)
    print ("  def oCAT(str1,str2):", file = file);
    print ("      if str1 > str2:", file = file);
    print ("          return str1 + str2", file = file);
    print ("      else:", file = file);
    print ("          return str2 + str1", file = file);
    print ("~~~", file = file)

    print ("\n### Test vectors ordered concatenation\n", file = file)
    
    print ("~~~", file = file)
    print ("  string comparison for oCAT:", file = file)    
    print ('    b"\\0" > b"\\0\\0" ==', b"\0" > b"\0\0", file = file)
    print ('    b"\\1" > b"\\0\\0" ==', b"\1" > b"\0\0", file = file)
    print ('    b"\\0\\0" > b"\\0" ==', b"\0\0" > b"\0", file = file)
    print ('    b"\\0\\0" > b"\\1" ==', b"\0\0" > b"\1", file = file)
    print ('    b"\\0\\1" > b"\\1" ==', b"\0\1" > b"\1", file = file)
    print ('    b"ABCD" > b"BCD" ==', b"ABCD" > b"BCD", file = file)
    print ('', file = file)

    tv_output_byte_array(oCAT(b"ABCD",b"BCD"), 
                         test_vector_name = 'oCAT(b"ABCD",b"BCD")', 
                         line_prefix = "  ", max_len = 60, file = file);
    tv_output_byte_array(oCAT(b"BCD",b"ABCDE"), 
                         test_vector_name = 'oCAT(b"BCD",b"ABCDE")', 
                         line_prefix = "  ", max_len = 60, file = file);
    print ("~~~", file = file)



def zero_bytes(length):
    result = b"\0" * length
    return result

def generator_string(PRS,DSI,CI,sid,s_in_bytes):
    """
    Concat all input fields with prepended length information.
    Add zero padding in the first hash block between PRS and DSI.
    """
    len_zpad = max(0,s_in_bytes - 1 - len(prepend_length_to_bytes(PRS)))
    return (prefix_free_cat(PRS, zero_bytes(len_zpad), DSI, CI, sid), len_zpad)

def random_bytes(length):
    values = [randint(0, 255) for i in range(length)]
    result = b""
    for v in values:
        result += v.to_bytes(1, 'little')
    return result

