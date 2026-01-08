import csv_parser

f = open(args[0])
if (args.length() > 1 && args[1] == "nn")
    csv_parser.dict_reader(f, dialect=csv_parser.Dialects.Dialect(quoting=csv_parser.Dialects.Quoting.NON_NUMERIC)).length()
else
    csv_parser.dict_reader(f).length()
~f.close()
