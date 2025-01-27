#Include 'Protheus.ch'
 
User function FINA910F()
 
Local aRet := {} // Array com os dados do Banco, AgÃªncia e Conta Corrente a serem gravadas na tabela SE1 e SE5.
 
//Alert("FINA910F")
aAdd (aRet,PADR("341",TamSX3("E1_PORTADO")[1])) // Numero do banco que serah gravado na SE1->E1_PORTADO
aAdd (aRet,PADR("0910",TamSX3("E1_AGEDEP")[1])) // Numero da agencia que serah gravada no campo SE1->E1_AGENCIAA
aAdd (aRet,PADR("02409",TamSX3("E1_CONTA")[1])) // Numero da conta corrente
 
Return aRet
