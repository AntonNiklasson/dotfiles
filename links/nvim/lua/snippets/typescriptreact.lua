local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("typescriptreact", {
	s("fc", {
		t("const "),
		i(1, "Component"),
		t(": FC<{"),
		i(2, "active: boolean"),
		t("}> = ({ children }) => {"),
		t({ "", "  return <div>{children}</div>" }),
		t({ "", "}" }),
		t({ "", "" }),
	}),

	ls.parser.parse_snippet(
		"motion",
		[[
    <motion.${1:div}
      variants={{
        hidden: {
          ${2}
        },
        visible: {
          ${3}
        },
      }}
      initial='hidden'
      animate='visible'
      exit='hidden'
      transition={{
        duration: 0.2,
      }}
    >
      {children}
    </motion.${1:div}>]]
	),
})
