#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ STMenu       º Autor ³  Microsiga     º Data ³  11/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PE executado para incluir opcoes na lista de funcoes do    º±±
±±º          ³ novo PDV (botao F2).                                       º±±
±±º          ³                                                            º±±
±±º          ³	A primeira posicao do array e' o nome do item de Menu.	  º±±
±±º          ³	A segunda posicao, e' a acao que sera tomada apos o       º±±
±±º          ³	clique no item do menu.                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/* Substituido pelo Ponto de Entrada STMenEdt
User Function STMenu()

Local aRetMenu 	:= {}

AADD( aRetMenu , { 'SL-Troca/Devolucao' 			, 'U_SAVC004()' 	})
AADD( aRetMenu , { 'SL-Cancelamento Troca/Devolucao', 'U_SAVC005()' 	})
AADD( aRetMenu , { 'SL-Cadastro Cliente' 			, 'U_NOVOCLI()'	 	})
AADD( aRetMenu , { 'SL-Ticket Defeito'  			, 'T_SYVA043(1)' 	})
AADD( aRetMenu , { 'SL-Impressão Ticket Defeito'	, 'T_SYVA043(2)' 	})

Return aRetMenu
*/

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ STMenu       º Autor ³  Microsiga     º Data ³  25/08/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PE para inclusao ou exclusao de opcoes no menu F2 do novo  º±±
±±º          ³ PDV.					                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function STMenEdt()

Local aOldMenu 	:= PARAMIXB[1]
Local aNewMenu  := {}
Local aOrdMenu  := {}
Local nPos
Local nX

// Ordem das rotinas
AADD( AORDMENU, "ENCERRAMENTO DE CAIXA" )
//AADD( AORDMENU, "SANGRIA DE CAIXA" )
//AADD( AORDMENU, "SUPRIMENTO DE CAIXA" )
//AADD( AORDMENU, "CADASTRO DE CLIENTES" )
//AADD( AORDMENU, "VALE PRESENTE/CRÉDITO" )
AADD( AORDMENU, "INFORMAR CPF" )
AADD( AORDMENU, "ALTERAR VENDEDOR" )
AADD( AORDMENU, "CANCELAR VENDA" )
AADD( AORDMENU, "REIMPRIMIR NFC-E" )
AADD( AORDMENU, "TEF - GERENCIAIS" )
//AADD( AORDMENU, "REIMPRIMIR SAT" )
AADD( AORDMENU, "VALE TROCA" )
AADD( AORDMENU, "RECEBIMENTO DE TÍTULO" )
AADD( AORDMENU, "ESTORNO DE TÍTULO" )
//AADD( AORDMENU, "CANCELAR RECEBIMENTO" )


// Inclui novas opcoes
AADD( aNewMenu , { "", "VA-Cadastro de Clientes"	 , "U_SYCADCLI()"	, "" })

// Inclui novas opcoes
AADD( aNewMenu , { "", "VA-Devolução"	 , "U_SYTRCDEV()"	, "" })

// Inclui opcoes ordenas
For nX:=1 To Len(aOrdMenu)
	nPos := AScan( aOldMenu, {|x| UPPER(AllTrim(x[2])) == aOrdMenu[nX] } )
	If nPos > 0 
		AADD( aNewMenu, AClone(aOldMenu[nPos]) )
	EndIf
Next nX

// Renumera itens
For nX:=1 To Len(aNewMenu)
	aNewMenu[nX][1] := AllTrim(STR(nX))
Next nX

Return aNewMenu