#Include 'Protheus.ch'
#Include 'rwmake.ch'

#Define ENTER CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLERTXT    บAutor  ณ                    บ Data ณ  01/13/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrograma que Le um arquivo TXT e devolve um Array com as    บฑฑ
ฑฑบ          ณlinhas do arquivo                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
                       
User Function ValImpCF()

Local cFile  	:= Space(255)
Local aRetorn	:= {}
Local cArqTxt	:= ""
Local nHdl		:= 0
Local nTamArq	:= 0
Local nLinhas	:= 0
Local nRecno	:= 0
Local nCont		:= 0          
Local aCabec	:= {}
Local aItens	:= {}
Local cNumPed	:= ""  
Local cTes	  	:= SuperGetMv("VL_TESCF",.F.,"555")
Local cCliente	:= ""
Local cLoja		:= ""
Local cReg		:= ""
Local aCabec	:= {}
Local aItens	:= {}
Local aLinha	:= {}
Local cItem		:= ""          
Local dDtBkp	:= dDatabase        
Local oNFiscal	:= Nil    
Local cCliPad	:= SuperGetMV("VL_CLIPAD",.F.,"519192")
Local cLjPad	:= SuperGetMV("VL_LJPAD",.F.,"00")
Private lMsErroAuto	:= .F.

Default cFile := ""

//+---------------------------------------------------------------------+
//| Chama tela para abertura de arquivo                                 |
//+---------------------------------------------------------------------+
BuscaTXT(@cFile)


If Empty(Alltrim(cFile))
	Alert("Nao existem arquivos para importar. Processo ABORTADO")
	Return.F.
EndIf

//+---------------------------------------------------------------------+
//| Abertura do arquivo texto                                           |
//+---------------------------------------------------------------------+
cArqTxt := cFile

nHdl := fOpen(cArqTxt,0 )
IF nHdl == -1
	IF FERROR()== 516
		ALERT("Feche o programa que gerou o arquivo.")
	EndIF
EndIf

//+---------------------------------------------------------------------+
//| Verifica se foi possํvel abrir o arquivo                            |
//+---------------------------------------------------------------------+
If nHdl == -1
	MsgAlert("O arquivo de nome "+cFile+" nao pode ser aberto! Verifique os parametros.","Atencao!" )
	Return
Endif


FSEEK(nHdl,0,0 )
nTamArq := FSEEK(nHdl,0,2 )
FSEEK(nHdl,0,0 )
fClose(nHdl)

FT_FUse(cFile )  //abre o arquivo
FT_FGoTop()         //posiciona na primeira linha do arquivo
nTamLinha := Len(FT_FREADLN() ) //Ve o tamanho da linha
FT_FGOTOP()

//+---------------------------------------------------------------------+
//| Verifica quantas linhas tem o arquivo                               |
//+---------------------------------------------------------------------+
nLinhas := FT_FLastRec()

While !FT_FEOF()
	IF nCont > nLinhas
		exit
	endif

	cLinha	:= Alltrim(FT_FReadLn())
	nRecno	:= FT_FRecno() // Retorna a linha corrente
	
	If (SubStr(cLinha,1,1) == "E" .AND. cReg == "G") .OR. Empty(AllTrim(SubStr(cLinha,1,1)))  
		DbSelectArea("SF2")
		DbSetOrder(1)
		If !DbSeek(xFilial("SF2") + cNum + cSerie + cCliente + cLoja )  
		
			MATA410(aCabec,aItens,3)
		    If !lMsErroAuto             
		 	 	ConOut("Incluido com sucesso! "+SC5->C5_NUM)           
			    oNFiscal := ClsCenFat():New()
			    oNfiscal:SetSerie(cSerie)
			     
			    oNFiscal:AddCabec( "PEDIDO", SC5->C5_NUM, 1 )
			    oNFiscal:AddCabec( "DOCUMENTO", cNum , 1 )
			    oNFiscal:AddCabec( "F2_EMISSAO", SC5->C5_EMISSAO, 1 )
			    
			    If !oNFiscal:GeraNFPed()
			    	Conout("Erro oNFiscal:GeraNFPed()" + oNFiscal:GetMensagem())
			    EndIf		     
			Else
		    	ConOut("Erro na inclusao!")
		        MostraErro()
			EndIf	
			
		EndIf
		     
	    aCabec	:= {}
		aItens	:= {}
		aLinha	:= {}	
		lMsErroAuto := .F.	 
	
	EndIf
	
	cReg 	:= SubStr(cLinha,1,1) 
		
	If cReg == "E"        
		
		cNum 	:= SubStr(cLinha, 3, 9)
		cSerie	:= SubStr(cLinha, 12, 3)
		dEmissao:= SubStr(cLinha, 15, 8)   
		cNome	:= SubStr(cLinha, 29, 40)
		dDatabase := STod(dEmissao)
	
		cCnpj	:= SubStr(cLinha, 69, 11)
		
		If Empty(cCnpj)
			cCliente	:= cCliPad
			cLoja		:= cLjPad		
	
		Else
			DbSelectArea("SA1")
			DbSetOrder(3)		
			If DbSeek(xFilial("SA1") + cCnpj )
				cCliente	:= SA1->A1_COD
				cLoja		:= SA1->A1_LOJA
			Else                           
				cCliente	:= GetSXENum("SA1", "A1_COD")
				cLoja		:= "00"
				
				RecLock("SA1", .T.)
				SA1->A1_FILIAL	:= xFilial("SA1")
				SA1->A1_COD		:= cCliente
				SA1->A1_LOJA	:= cLoja
				SA1->A1_NOME	:= AllTrim(cNome)
				SA1->A1_PESSOA	:= "J"
				SA1->A1_NREDUZ	:= AllTrim(cNome)
				SA1->A1_END		:= "."
				SA1->A1_BAIRRO	:= "."
				SA1->A1_MUN		:= "."     
				SA1->A1_CGC		:= cCnpj
				SA1->A1_EST		:= "PE"
	            SA1->(MsUnlock())
	            
	            ConfirmSX8()
	        EndIf                                           
  		EndIf
  		
  		cNumPed := GetSXENum("SC5", "C5_NUM")       
  		RollBAckSx8()
		aadd(aCabec,{"C5_NUM"   	,cNumPed	,Nil})
        aadd(aCabec,{"C5_TIPO" 		,"N"		,Nil})
        aadd(aCabec,{"C5_CLIENTE"	,cCliente	,Nil})
        aadd(aCabec,{"C5_LOJACLI"	,cLoja		,Nil})
        aadd(aCabec,{"C5_CONDPAG"	,"001"		,Nil})   
        aadd(aCabec,{"C5_TIPO"		,"N"		,Nil})     
        aadd(aCabec,{"C5_NATUREZ"	,"300000002",Nil})     
        aadd(aCabec,{"C5_CLIENT"	,cCliPad	,Nil})
        aadd(aCabec,{"C5_LOJAENT"	,cLjPad		,Nil})
        
  ElseIf cReg == "G"
		
		cProd	:= SubStr(cLinha, 3,  13)     
		nValUnt	:= Val(SubStr(cLinha, 41, 12))/1000
		nValTot	:= Val(SubStr(cLinha, 26, 15))/1000
		nValDes	:= Val(SubStr(cLinha, 53, 13))/100
		cUN		:= SubStr(cLinha, 66, 02)  
		cItem	:= SubStr(cLinha, 82, 02) 
		nQtde	:= Val(SubStr(cLinha, 17, 09))/100   
		
		nValUnt := nValtot
		
		DbSelectArea("SB1")                                                   
		DbSetOrder(1)
		If !DbSeek(xFilial("SB1") + cProd )
			RecLock("SB1",.T.)
			SB1->B1_FILIAL	:= xFilial("SB1")
			SB1->B1_COD		:= cProd
			SB1->B1_DESC	:= "CADASTRO A COMPLETAR"
			SB1->B1_UM		:= cUN
			SB1->B1_TIPO	:= "ME"
			SB1->B1_LOCPAD	:= "01"
			SB1->B1_POSIPI	:= "99999999"
			SB1->B1_ORIGEM	:= "1"
			SB1->(MsUnlock())
		EndIf		
			
		aLinha := {}
        aadd(aLinha,{"C6_ITEM"		,cItem					,Nil})
        aadd(aLinha,{"C6_PRODUTO"	,cProd					,Nil})
        aadd(aLinha,{"C6_QTDVEN"	,nQtde					,Nil})
        aadd(aLinha,{"C6_PRCVEN"	,nValUnt				,Nil})
        aadd(aLinha,{"C6_PRUNIT"	,nValUnt		  		,Nil})
        aadd(aLinha,{"C6_VALOR"		,nValUnt*nQtde			,Nil})
        aadd(aLinha,{"C6_VALDESC"	,nValDes				,Nil})
        aadd(aLinha,{"C6_TES"		,cTes					,Nil})
        aadd(aItens,aLinha)
	
	EndIf
	
	FT_FSKIP()
	nCont++
EndDo                 
FT_FUSE()
fClose(nHdl)

If Len(aLinha) > 0 .AND. Len(aCabec) > 0           
	DbSelectArea("SF2")
	DbSetOrder(1)
	If !DbSeek(xFilial("SF2") + cNum + cSerie + cCliente + cLoja )  
	
		MATA410(aCabec,aItens,3)
	
	    If !lMsErroAuto             
	 	 	ConOut("Incluido com sucesso! "+SC5->C5_NUM)           
		    oNFiscal := ClsCenFat():New()
		    oNfiscal:SetSerie(cSerie)
		     
		    oNFiscal:AddCabec( "PEDIDO", SC5->C5_NUM, 1 )
		    oNFiscal:AddCabec( "DOCUMENTO", cNum , 1 )
		    oNFiscal:AddCabec( "F2_EMISSAO", SC5->C5_EMISSAO, 1 )
		    
		    If !oNFiscal:GeraNFPed()
		    	Conout("Erro oNFiscal:GeraNFPed()" + oNFiscal:GetMensagem())
		    EndIf		     
		Else
	    	ConOut("Erro na inclusao!")
	        MostraErro()
		EndIf	
    EndIf
     
    aCabec	:= {}
	aItens	:= {}
	aLinha	:= {}	
	lMsErroAuto := .F.	
	
EndIf       

dDatabase := dDtBkp

Return (aRetorn)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ BuscaTXT บ Autor ณ AP5 IDE            บ Data ณ  07/02/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Programa responsavel em buscar o arquivo na maquina do 	  บฑฑ
ฑฑบ          ณ o perador                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function BuscaTXT(cFile)

Private cEdit1	 := Space(15)
Private cEdit2	 := Space(02)
Private cEdit3	 := Space(25)
Private cEdit4	 := Space(25)
Private oEdit1
Private oEdit2
Private oEdit3
Private oEdit4
Private nPanel  := 1,;
oDlg, oBmp1, oBmp2, oGet,;
nOpca  := 0,;
cType  := "Arquivos TXT  | *.txt* ",;
dDatSvd:= dDataBase

DEFINE DIALOG oDlg FROM 000,000 TO 320,480 TITLE OemToAnsi('Importa็ใo de Cupons') PIXEL
@ 035, 050 TO 140, 230 OF oDlg PIXEL
@ 000, 050 BITMAP oBmp1 RESNAME "APLOGO" OF oDlg SIZE 100,200 NOBORDER  WHEN .F. PIXEL
@ 000, 000 BITMAP oBmp2 RESNAME "LOGIN"  OF oDlg SIZE 050,155 NOBORDER  WHEN .F. PIXEL

@ 120,070 MSGET oGet VAR cFile SIZE 125,10 PIXEL OF oDlg
@ 120,200 BUTTON OemToAnsi("...") SIZE 15,10 PIXEL OF oDlg ACTION cFile := Padr( cGetFile(cType, OemToAnsi("Selecionando o arquivo "+Subs(cType,1,6)),0,,.T.,GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE), 255 )

DEFINE SBUTTON FROM  145, 170 TYPE 1 ACTION (oDlg:End()) ENABLE PIXEL OF oDlg
DEFINE SBUTTON FROM  145, 200 TYPE 2 ACTION (nOpca := 0, oDlg:End()) ENABLE PIXEL OF oDlg
ACTIVATE DIALOG oDlg CENTERED


Return()