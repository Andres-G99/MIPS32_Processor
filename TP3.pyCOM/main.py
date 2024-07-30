from pyASM import pyASM

def main():
    file = input_file("tester.asm")
    #print(file)

    asm = pyASM()
    if asm.validate_asm_code(file) == True:
        print("Syntaxis OK!")
        asm.assamble(file)
'''
    try:
        asm = pyASM()
        if asm.validate_asm_code(file) == True:
            print("Syntaxis OK!")
            asm.assamble(file)

    except Exception as e:
        print(e)
        print("\nCompilation failed...")
        exit(1)
'''



def input_file(file_path: str) -> str:
    try:
        with open(file_path, 'r') as file:
            content = file.read()
        return content
    except FileNotFoundError:
        return "File not found."
    except IOError:
        return "Error reading file."



if __name__ == '__main__':
    main()