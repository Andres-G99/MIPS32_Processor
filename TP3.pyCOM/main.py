from pyASM import pyASM

def main():
    file = input_file("test.asm")
    #print(file)

    asm = pyASM()
    asm.assamble(file)

    #try:
        #asm = pyASM()
        #asm.assamble(file)
    #    pass
    #except Exception as e:
    #    print(e)
    #    print("\nCompilation failed...")
    #    exit(1)




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