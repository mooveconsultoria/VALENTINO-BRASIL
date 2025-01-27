#include "rwmake.ch"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} novo
Permite a manutenção de dados armazenados em ZZB.

@author    TOTVS | Developer Studio - Gerado pelo Assistente de Código
@version   1.00
@since     22/07/2019
/*/
//------------------------------------------------------------------------------------------
user function VAFAT030()
	
	//Indica a permissão ou não para a operação (pode-se utilizar 'ExecBlock')
	local cVldAlt := ".T." // Operacao: ALTERACAO
	local cVldExc := ".T." // Operacao: EXCLUSAO
	
	//trabalho/apoio
	local cAlias
	
	//--< procedimentos >-----------------------------------------------------------------------
	
	cAlias := "ZZB"
	chkFile(cAlias)
	dbSelectArea(cAlias)
	
	//indices
	dbSetOrder(1)
	
	//Título a ser utilizado nas operações
	private cCadastro := "Cadastro de Amarração TES x NCM"
	private aCores		:= {}
	
	Aadd( aCores, { "ZZB_TPVDA=='1'", "BR_VERDE"		} ) // "Venda Presencial"
	Aadd( aCores, { "ZZB_TPVDA=='2'", "BR_AMARELO" 	} ) // "Venda a Distância"
	Aadd( aCores, { "ZZB_TPVDA=='3'", "BR_AZUL" 		} ) // "Demostração"

	aRotina := {	{ "Pesquisar"		, "AxPesqui"		, 0, 1},;
					{ "Visualizar"		, "AxVisual"		, 0, 2},;
					{ "Incluir"		, "AxInclui"		, 0, 3},;
					{ "Alterar"		, "AxAltera"		, 0, 4},;
					{ "Exlcuir"		, "AxDeleta"		, 0, 5},;
					{ "Legendas"		, "U_VFT020Leg"	, 0, 6}}
	
	dbSelectArea(cAlias)
	mBrowse( 6, 1, 22, 75, cAlias,,,,,,aCores,,,,,,,,)
	
return