#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RwMake.ch"
#include 'tbiconn.ch'



/*
* Funcao		:	TELAVERBAS
* Autor			:	Tiago Maniero
* Data			: 	20/05/2021
* Descricao		:	Relatório RH Valores acumulados por competencia
*/
user function TELAVERBAS()
    local   oArq     := nil
    local cAlias     := ""
    Private lInverte := .F.
	Private cMark    := GetMark()   
	Private aVerbas  := {}


    oArq := criaTrab()
    cAlias := consulTela()
    if (cAlias)->(!eof())
        populaTab(cAlias)
        montaGrid()
    endif
    oArq:delete()


return aVerbas


static function criaTrab()
	local _aStru := {}
	local oArq   := nil


	aAdd(_aStru,{"OK","C",2,0})
	aAdd(_aStru,{"CODIGO","C",3,0})
	aAdd(_aStru,{"DESCRICAO","C",40,0})
	aAdd(_aStru,{"TIPO","C",1,0})
	
	oArq := fwTemporaryTable():new("TTRB",_aStru)
	
	oArq:create()


return oArq


static function montaGrid()
    local oDlg		 := nil
	local oMark		 := nil
	local bOK		 := {||arrayRetorno(),oDlg:end()}
	local bCancel	 := {||oDlg:end()}
	local aCoords	 := FWGetDialogSize( oMainWnd )
	local aCpoBro    := camposTela()


	Define MsDialog oDlg Title "Contratos para Pagamento Apuração"  From aCoords[1], aCoords[2] to aCoords[3], aCoords[4]-20 Pixel

	DbSelectArea("TTRB")
	DbGotop()
	
	//Cria a MsSelect
	oMark := MsSelect():New("TTRB","OK","",aCpoBro,@lInverte,@cMark,{30,12,400,600})
	oMark:bMark := {| | Disp(@oMark)} 
    
    
	Activate MsDialog oDlg Center on init EnchoiceBar( oDlg, bOK,bCancel,,,,,.f.,.f.,.t.,.t.,.f.)

	TTRB->(DbCloseArea())


return


static function camposTela()
	local aRet := {}

	aRet	:= {;
	{ "OK"       ,, "Mark"     ,"@!"},;
	{ "CODIGO"   ,, "Código"   ,"@X"},;			
	{ "DESCRICAO",, "Descrição","@X"},;			
	{ "TIPO"     ,, "Tipo"     ,"@X"}}			


return aRet


static function consulTela()
    local cQuery := ""
    local cAlias := getNextAlias()


    cQuery += "SELECT RV_COD, RV_DESC, RV_TIPO " + CRLF
    cQuery += " FROM " + retSqlTab("SRV") + CRLF
    cQuery += "  WHERE SRV.D_E_L_E_T_ = ' '"  + CRLF

    tcQuery cQuery new alias &cAlias

return cAlias


static function populaTab(cAlias)

    while (cAlias)->(!eof())
        dbSelectArea("TTRB")
        recLock("TTRB",.T.)
            TTRB->CODIGO := (cAlias)->RV_COD
            TTRB->DESCRICAO := (cAlias)->RV_DESC
            TTRB->TIPO := (cAlias)->RV_TIPO
            msUnlock()
            (cAlias)->(dbSkip())
    endDo
    (cAlias)->(dbCloseArea())

return


Static Function disp(oMark)
	
	RecLock("TTRB",.F.)
	
	if Marked("OK")
		TTRB->OK := cMark
	else	
		TTRB->OK := ""
	endif             
	msUnlock()
	oMark:oBrowse:Refresh()
	
Return


static function arrayRetorno()
    local aAux  := {}

    dbSelectArea("TTRB")
    dbGotop()
    while TTRB->(!eof())
        if Marked("OK")
            aAdd(aAux,TTRB->CODIGO)
            aAdd(aAux,TTRB->DESCRICAO)
            aAdd(aVerbas,aAux)
            aAux := {}
        endif
        TTRB->(dbSkip())
    endDo

    if len(aVerbas) == 0
        while TTRB->(!eof())
            aAdd(aAux,TTRB->CODIGO)
            aAdd(aAux,TTRB->DESCRICAO)
            aAdd(aVerbas,aAux)
            aAux := {}
        
            TTRB->(dbSkip())
        endDo
    endif


return
