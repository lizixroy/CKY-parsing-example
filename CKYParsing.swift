class ParseTreeNode {
	let nonTerminal: String
	let leftNode: ParseTreeNode?
	let rightNode: ParseTreeNode?	
	init(nonTerminal: String, leftNode: ParseTreeNode?, rightNode: ParseTreeNode?) {
		self.nonTerminal = nonTerminal
		self.leftNode = leftNode
		self.rightNode = rightNode
	}
}

class Language {
	private let separator = ", "
	private var productions = [String: [String]]()
	
	init(setUpProductionRules: Bool) {
		if setUpProductionRules {
			self.setUpProductionRules()		
		}
	}
	
	func recognize(arr1 arr1: [ParseTreeNode], arr2: [ParseTreeNode]) -> [ParseTreeNode]? {
		var nodes = [ParseTreeNode]()
		for node1 in arr1 {
			for node2 in arr2 {
				let key = [node1.nonTerminal, node2.nonTerminal].joinWithSeparator(separator)
				if let nonTerminals = productions[key] {
					for nonTerminal in nonTerminals {
						let node = ParseTreeNode(nonTerminal: nonTerminal, leftNode: node1, rightNode: node2)
						nodes.append(node)
					}
				}
			}
		}
		return (nodes.count > 0) ? nodes : nil
	}
	
	private func setUpProductionRules() {				
		addGrammar(leftHandSide: "S", rightHandSide: ["NP", "VP"])
		addGrammar(leftHandSide: "S", rightHandSide: ["X1", "VP"])
		addGrammar(leftHandSide: "X1", rightHandSide: ["Aux", "NP"])
		addGrammar(leftHandSide: "S", rightHandSide: ["Verb", "NP"])		
		addGrammar(leftHandSide: "S", rightHandSide: ["X2", "PP"])		
		addGrammar(leftHandSide: "S", rightHandSide: ["Verb", "PP"])		
		addGrammar(leftHandSide: "S", rightHandSide: ["VP", "PP"])		
		addGrammar(leftHandSide: "NP", rightHandSide: ["Det", "Nominal"])
		addGrammar(leftHandSide: "Nominal", rightHandSide: ["Nominal", "Noun"])		
		addGrammar(leftHandSide: "Nominal", rightHandSide: ["Nominal", "PP"])
		addGrammar(leftHandSide: "VP", rightHandSide: ["Verb", "NP"])		
		addGrammar(leftHandSide: "VP", rightHandSide: ["X2", "PP"])		
		addGrammar(leftHandSide: "X2", rightHandSide: ["Verb", "NP"])
		addGrammar(leftHandSide: "VP", rightHandSide: ["Verb", "PP"])
		addGrammar(leftHandSide: "VP", rightHandSide: ["VP", "PP"])
		addGrammar(leftHandSide: "PP", rightHandSide: ["Preposition", "NP"])			
		// Lexicon
		addLexicon(leftHandSide: "S", rightHandSide: ["book", "include", "prefer"])
		addLexicon(leftHandSide: "NP", rightHandSide: ["I", "she", "me"])	
		addLexicon(leftHandSide: "Nominal", rightHandSide: ["book", "flight", "meal", "money"])	
		addLexicon(leftHandSide: "VP", rightHandSide: ["book", "include", "prefer"])				
		addLexicon(leftHandSide: "Det", rightHandSide: ["the", "this", "a"])	
		addLexicon(leftHandSide: "Noun", rightHandSide: ["book", "flight", "meal", "money"])
		addLexicon(leftHandSide: "Verb", rightHandSide: ["book", "include", "prefer"])
		addLexicon(leftHandSide: "Pronoun", rightHandSide: ["I", "she", "me"])
		addLexicon(leftHandSide: "Proper-Noun", rightHandSide: ["Houston", "NWA"])
		addLexicon(leftHandSide: "Aux", rightHandSide: ["does"])
		addLexicon(leftHandSide: "Preposition", rightHandSide: ["from", "to", "on", "near", "through"])
		addLexicon(leftHandSide: "NP", rightHandSide: ["TWA", "Houston"])				
	}
	
	func printGrammarAndLexicon() {		
		var dict = [String: [String]]()
		var keys = productions.keys
		for key in keys {
			let value = productions[key]!
			for nonTerminal in value {
				if dict[nonTerminal] == nil {
					dict[nonTerminal] = [key]
				} else {
					dict[nonTerminal]?.append(key)
				}
			}
		}
		
		keys = dict.keys
		for key in keys {
			let array = dict[key]! 
			for str in array {	
				print("\(key) -> \(str)")
			}		
		}
	}
	
	func addGrammar(leftHandSide leftHandSide: String, rightHandSide: [String]) {
		let key = rightHandSide.joinWithSeparator(separator)
		if productions[key] != nil {
			productions[key]?.append(leftHandSide)
		} else {
			productions[key] = [leftHandSide]
		}
	}
	
	func addLexicon(leftHandSide leftHandSide: String, rightHandSide: [String]) {
		for word in rightHandSide {
			if productions[word] != nil {
				productions[word]?.append(leftHandSide)
			} else {
				productions[word] = [leftHandSide]
			}
		}
	}
		
	func recognize(rightHandSide: [String]) -> [String]? {
		let key = rightHandSide.joinWithSeparator(separator)
		return productions[key]
	}
	
}

class LanguageTests {	
	
	var language = Language(setUpProductionRules: false)	
	
	func testAddGrammar() {
		let leftHandSide = "S"
		let rightHandSide = ["NP", "VP"]
		language.addGrammar(leftHandSide: leftHandSide, rightHandSide: rightHandSide)
		
		if let nonTerminals = language.recognize(rightHandSide) {
			assert([leftHandSide] == nonTerminals, "strings should match")
			print(".")
		} else {
			print("Failed: nonTerminals should not be nil")
		}
	}
	
	func testAddLexicon() {
		let leftHandSide = "Pronoun"
		let rightHandSide = ["I", "she", "me"]
		language.addLexicon(leftHandSide: leftHandSide, rightHandSide: rightHandSide)
		if let nonTerminalsA = language.recognize(["I"]), let nonTerminalsB = language.recognize(["she"]), let nonTerminalsC = language.recognize(["me"]) {
			assert(nonTerminalsA == nonTerminalsB, "should match")
			assert(nonTerminalsB == nonTerminalsC, "should match")
			assert(nonTerminalsC == [leftHandSide], "should match")
			print(".")		
		} else {
			print("Failed: nonTerminals should not be nil")
		}
	}
	
	func testRecognize() {
		language = Language(setUpProductionRules: false)		
		language.addGrammar(leftHandSide: "S", rightHandSide: ["NP", "VP"])		
		let leftNode = ParseTreeNode(nonTerminal: "NP", leftNode: nil, rightNode: nil)		
		let rightNode = ParseTreeNode(nonTerminal: "VP", leftNode: nil, rightNode: nil)
		let newNodeArr = language.recognize(arr1: [leftNode], arr2: [rightNode])
		if let _newNodeArr = newNodeArr {
			let newNode = _newNodeArr[0]
			assert(newNode.nonTerminal == "S", "nonTerminals should match")
			assert(newNode.leftNode != nil, "should have leftNode")
			assert(newNode.rightNode != nil, "should have rightNode")
			assert(newNode.leftNode?.nonTerminal == "NP", "nonTerminals should match")
			assert(newNode.rightNode?.nonTerminal == "VP", "nonTerminals should match")
			print(".")
		} else {
			print("Failed: newNodeArr should not be nil")
		}
	}
}

class CKYParser {
	func parse(words words: [String], language: Language) -> [[[ParseTreeNode]]] {
		let wordCount = words.count
		var table = [[[ParseTreeNode]]]()
		for _ in 0...words.count - 1 {
			let array = [[ParseTreeNode]](count: wordCount, repeatedValue: [ParseTreeNode]())
			table.append(array)
		}
		// populate lexicon. assuming all the words are in our lexicon
		for index in 0...words.count - 1 {
			let word = words[index]
			let nonTerminals = language.recognize([word])!
			for nonTerminal in nonTerminals {
				table[index][index].append(ParseTreeNode(nonTerminal: nonTerminal, leftNode: nil, rightNode: nil))
			}
		}
		for col in 0...wordCount - 1 {
			for row in (0...wordCount - 1).reverse() {
				var t = row
				while t + 1 <= col {
					let arr1 = table[row][t]
					let arr2 = table[t + 1][col]
					if arr1.count == 0 || arr2.count == 0 {
						t += 1
						continue
					}
					if let nonTerminals = language.recognize(arr1: arr1, arr2: arr2) {
						for nonTerminal in nonTerminals {
							table[row][col].append(nonTerminal)
						}
					}
					t += 1
				}
			}
		}
		return table
	}
}

class CKYParserTests {
	func testParse() {
		let language = Language(setUpProductionRules: false)
		language.addLexicon(leftHandSide: "Nominal", rightHandSide: ["book"])
		language.addLexicon(leftHandSide: "Det", rightHandSide: ["the"])
		language.addGrammar(leftHandSide: "NP", rightHandSide: ["Det", "Nominal"])
		let parser = CKYParser()
		let table = parser.parse(words: ["the", "book"], language: language)		
		assert(table[0][1].count == 1)
		let node = table[0][1][0]
		assert(node.nonTerminal == "NP", "shold match")
		assert(node.leftNode != nil, "left node should not be nil")
		assert(node.rightNode != nil, "right node should not be nil")
		assert(node.leftNode?.nonTerminal == "Det")
		assert(node.rightNode?.nonTerminal == "Nominal")
		print(".")
	}
}

/* Unit Tests */
let langTest = LanguageTests()
langTest.testAddGrammar()
langTest.testAddLexicon()
langTest.testRecognize()
let parserTest = CKYParserTests()
parserTest.testParse()

/* Parsing Example */
let lang = Language(setUpProductionRules: true)
let parser = CKYParser()
let table = parser.parse(words: ["book", "the", "flight", "through", "Houston"], language: lang)
let nodes = table[0][4]

// a nice printing function is needed in order to print out all the trees in "nodes". I will get to it once I have some time :)