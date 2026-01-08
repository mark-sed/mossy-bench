import md_parser

f = open(args[0])
parsed = md_parser.parse_md(f.read())
~f.close()
for (e: parsed)
    e.to_txt()++"\n"