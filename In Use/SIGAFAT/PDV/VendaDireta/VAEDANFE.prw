#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TBICONN.CH" 
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE IMP_SPOOL 2

#DEFINE VBOX       080
#DEFINE VSPACE     008
#DEFINE HSPACE     010
#DEFINE SAYVSPACE  008
#DEFINE SAYHSPACE  008
#DEFINE HMARGEM    030
#DEFINE VMARGEM    030
#DEFINE MAXITEM    022                                                // Máximo de produtos para a primeira página
#DEFINE MAXITEMP2  049                                                // Máximo de produtos para a pagina 2 em diante
#DEFINE MAXITEMP2F 069                                                // Máximo de produtos para a página 2 em diante quando a página não possui informações complementares
#DEFINE MAXITEMP3  025                                                // Máximo de produtos para a pagina 2 em diante (caso utilize a opção de impressao em verso) - Tratamento implementado para atender a legislacao que determina que a segunda pagina de ocupar 50%.
#DEFINE MAXITEMC   038                                                // Máxima de caracteres por linha de produtos/serviços
#DEFINE MAXMENLIN  088                                               // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXMSG     013                                                // Máximo de dados adicionais por página
#DEFINE MAXVALORC  009                                                // Máximo de caracteres por linha de valores numéricos

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³VaEDanfe ³ Autor ³ Eduardo Riera         ³ Data ³16.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rdmake de exemplo para impressão da DANFE no formato Retrato³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function VaEDanfe(aFormas,aPayment)

Local aArea     	:= GetArea()
Local cFilePrint	:= ""						//nome do arquivo de impressao do DANFE
Local cChave		:= ""						//valor da chave pesquisada no Profile do usuario
Local cIDEnt		:= ""						//codigo da entidade do servidor TSS
Local cPath 		:= ""						// Diretório onde o arquivo de relatório será salvo	
Local cSession		:= GetPrinterSession()
Local lRetAux		:= .T.
Local oDANFE		:= Nil						//objeto da classe FwMsPrinter
Local oSetup		:= Nil						//objeto da classe FwPrintSetup
Local oProcess		:= Nil						//objeto da classe MsNewProcess

Local nFlags			:= 0					//indica quais opcoes estarao disponiveis na configuracao da impressao
Local nDestination	:= 1					//SERVER
Local nOrientation	:= 1					//PORTRAIT
Local nPrintType		:= 6					//PDF
Local aDevice			:= {}

Local lExistNfe 		:= .F.

Private nConsNeg 	:= 0.4 // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.
Private nConsTex 	:= 0.5 // Constante para concertar o cálculo retornado pelo GetTextWidth.

Default aFormas	:= {}
Default aPayment	:= {}

cPath := "\VADANFE\"
MakeDir(cPath)

//Entidade configurada no servidor TSS
//cIDEnt := LjTSSIDEnt("55")

//Nome do arquivo que sera impresso: DANFE_ + ENTIDADE + AAAAMMSS + HHMMSS   
cFilePrint := "VAEDANFE" + DtoS(MSDate()) + StrTran(Time(),":","")

// Configuracoes de Impressao baseada no Profile
cChave := FWGetProfString(cSession, "LOCAL", "SERVER", .T.)
If cChave <> "SERVER"
	nDestination := 2	//CLIENT
EndIf

cChave := FWGetProfString(cSession, "ORIENTATION", "PORTRAIT", .T.)
If cChave <> "PORTRAIT"
	nOrientation := 2	//LANDSCAPE
EndIf

aDevice := {"DISCO","SPOOL","EMAIL","EXCEL","HTML","PDF"}
cChave := FWGetProfString(cSession, "PRINTTYPE", "SPOOL", .T.)
If Empty(cChave)
	cChave := "PDF"
EndIf
nPrintType := aScan( aDevice, {|x| x == cChave} )

// FWPrintSetup
nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN // indica quais opcoes estarao disponiveis
oSetup := FWPrintSetup():New(nFlags, "VAEDANFE")

oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
oSetup:SetPropert(PD_ORIENTATION , nOrientation)
oSetup:SetPropert(PD_DESTINATION , nDestination)
oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
oSetup:SetPropert(PD_PAPERSIZE   , 2)
oSetup:CQTDCOPIA := "01"

// Interface para o usuario configurar os parametros de impressao
lRetAux := oSetup:Activate() == PD_OK

If lRetAux
	// Atualiza os parametros no Profile
	FwWriteProfString( cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
	FwWriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       ), .T. )
	FwWriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )
EndIf

// FWMsPrinter
oDanfe:=FWMSPrinter():New(cFilePrint, IMP_PDF, .F., cPath, .T.)
oDanfe:SetCopies( Val(oSetup:CQTDCOPIA) )
oDanfe:SetResolution(78) //Tamanho estipulado para a Danfe
oDanfe:SetPortrait()
oDanfe:SetPaperSize(DMPAPER_A4)
oDanfe:SetMargin(60,60,60,60)
oDanfe:lServer := oSetup:GetProperty(PD_DESTINATION)==AMB_SERVER

// ----------------------------------------------
// Define saida de impressão
// ----------------------------------------------
If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
	oDanfe:nDevice := IMP_SPOOL
	// ----------------------------------------------
	// Salva impressora selecionada
	// ----------------------------------------------
	fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
	oDanfe:cPrinter := oSetup:aOptions[PD_VALUETYPE]

ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
	oDanfe:nDevice := IMP_PDF
	// ----------------------------------------------
	// Define para salvar o PDF
	// ----------------------------------------------
	oDanfe:cPathPDF := oSetup:aOptions[PD_VALUETYPE]

Endif

Private PixelX := odanfe:nLogPixelX()
Private PixelY := odanfe:nLogPixelY()

RptStatus({|lEnd| DanfeProc(@oDanfe,@lEnd,cIdEnt,@lExistNfe,aFormas,aPayment)},"Imprimindo Danfe...")

If lExistNfe
	oDanfe:Preview()//Visualiza antes de imprimir
Else
	Aviso("DANFE","Nenhuma NF-e a ser impressa nos parametros utilizados.",{"OK"},3)
EndIf

FreeObj(oDanfe)
oDanfe := Nil

RestArea(aArea)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DANFEProc ³ Autor ³ Eduardo Riera         ³ Data ³16.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rdmake de exemplo para impressão da DANFE no formato Retrato³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto grafico de impressao                    (OPC) ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DANFEProc(oDanfe,lEnd,cIdEnt,lExistNfe,aFormas,aPayment)

Local aArea      := GetArea()

//Imprime frente e verso 1=Sim e 2=Nao
MV_PAR05 := 2 

ImpDet(@oDanfe,aFormas,aPayment)
lExistNfe := .T.

RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpDet   ³ Autor ³ Eduardo Riera         ³ Data ³16.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Fluxo do Relatorio.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto grafico de impressao                    (OPC) ³±±
±±³          ³ExpC2: String com o XML da NFe                              ³±±
±±³          ³ExpC3: Codigo de Autorizacao do fiscal                (OPC) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpDet(oDanfe,aFormas,aPayment)

	PRIVATE oFont10N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)// 1
	PRIVATE oFont07N   := TFontEx():New(oDanfe,"Times New Roman",06,06,.T.,.T.,.F.)// 2
	PRIVATE oFont07    := TFontEx():New(oDanfe,"Times New Roman",06,06,.F.,.T.,.F.)// 3
	PRIVATE oFont08    := TFontEx():New(oDanfe,"Times New Roman",07,07,.F.,.T.,.F.)// 4
	PRIVATE oFont08N   := TFontEx():New(oDanfe,"Times New Roman",06,06,.T.,.T.,.F.)// 5
	PRIVATE oFont09N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)// 6
	PRIVATE oFont09    := TFontEx():New(oDanfe,"Times New Roman",08,08,.F.,.T.,.F.)// 7
	PRIVATE oFont10    := TFontEx():New(oDanfe,"Times New Roman",09,09,.F.,.T.,.F.)// 8
	PRIVATE oFont11    := TFontEx():New(oDanfe,"Times New Roman",10,10,.F.,.T.,.F.)// 9
	PRIVATE oFont12    := TFontEx():New(oDanfe,"Times New Roman",11,11,.F.,.T.,.F.)// 10
	PRIVATE oFont11N   := TFontEx():New(oDanfe,"Times New Roman",10,10,.T.,.T.,.F.)// 11
	PRIVATE oFont18N   := TFontEx():New(oDanfe,"Times New Roman",17,17,.T.,.T.,.F.)// 12
	PRIVATE OFONT12N   := TFontEx():New(oDanfe,"Times New Roman",11,11,.T.,.T.,.F.)// 12

	PrtDanfe(@oDanfe,aFormas,aPayment)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrtDanfe  ³ Autor ³Eduardo Riera          ³ Data ³16.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do formulario DANFE grafico conforme laytout no   ³±±
±±³          ³formato retrato                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrtDanfe()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto grafico de impressao                          ³±±
±±³          ³ExpO2: Objeto da NFe                                        ³±±
±±³          ³ExpC3: Codigo de Autorizacao do fiscal                (OPC) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrtDanfe(oDanfe,aFormas,aPayment)

Local aAuxCabec     := {} // Array que conterá as strings de cabeçalho das colunas de produtos/serviços.
Local aTamCol       := {} // Array que conterá o tamanho das colunas dos produtos/serviços.
Local aSitTrib      := {}
Local aSitSN        := {}
Local aTransp       := {}
Local aDest         := {}
Local aHrEnt        := {}
Local aFaturas      := {}
Local aItens        := {}
Local aISSQN        := {}
Local aSimpNac		:= {}
Local aTotais       := {}
Local aTotGeral		:= {}
Local aAux          := {}
Local aUF           := {}
Local aMensagem     := {}
Local aEspVol       := {}
Local aResFisco     := {} 
Local aIndImp	    := {}
Local aIndAux	    := {} 

Local nHPage        := 0
Local nVPage        := 0
Local nAuxH         := 0
Local nAuxH2        := 0
Local nX            := 0
Local nY            := 0
Local nL            := 0
Local nTamanho      := 0
Local nFolha        := 1
Local nFolhas       := 0
Local nItem         := 0

Local nMensagem     	:= 0
Local nBaseICM      	:= 0
Local nValICM       	:= 0
Local nValIPI       	:= 0
Local nPICM         	:= 0
Local nPIPI         	:= 0
Local nFaturas      	:= 0
Local nVTotal       	:= 0
Local nQtd          	:= 0
Local nVUnit        	:= 0
Local nVolume	    	:= 0
Local nLenDet			:= 0
Local nLenItens     	:= 0
Local nLenMensagens 	:= 0
Local nColuna	    	:= 0
Local nZ		    	:= 0 
Local nMaxCod	    	:= 20  //CUSTOMIZADO ASICS COMENTADO LINHA 10
Local nMaxDes	    	:= MAXITEMC 
Local nLinhavers    	:= 0
Local nMaxItemP2    	:= MAXITEM // Variável utilizada para tratamento de quantos itens devem ser impressos na página corrente 

Local cAux          	:= ""
Local cSitTrib      	:= ""
Local cUF		 		:= ""  
Local cMVCODREG		:= Alltrim( SuperGetMV("MV_CODREG", ," ") )
Local cChaveCont 		:= ""
Local cLogo      		:= FisxLogo("1")
Local cLogoD	    	:= ""
local cEndDest      	:= ""
Local cBairro			:= ""
Local cCEP				:= ""
Local cMunicipio		:= ""
Local cEstado			:= ""
Local cTelefone		:= ""
Local cInsc			:= ""
local cLogoTotvs 		:= "Powered_by_TOTVS.bmp"
local cStartPath 		:= GetSrvProfString("Startpath","")
Local cOrcamento		:= ""

Local lPreview      := .F.
Local lFlag         := .T.
Local lConverte     := GetNewPar("MV_CONVERT",.F.)
Local lMv_Logod     := If(GetNewPar("MV_LOGOD", "N" ) == "S", .T., .F.   )
Local lMv_ItDesc    := Iif( GetNewPar("MV_ITDESC","N")=="S", .T., .F. )
Local lFimpar	    := .T. 	                     
Local cDhCont		:= ""
Local cXJust		:= ""

Local cDescLogo		:= ""
Local cGrpCompany	:= ""
Local cCodEmpGrp	:= ""
Local cUnitGrp		:= ""
Local cFilGrp		:= ""

Local lPontilhado 	:= .F.

Private oNF       := ""
Private oEmitente := ""
Private oIdent    := ""
Private oDet      := ""
Private cDtHrRecCab := ""

nFaturas := Len(aPgtos)
oDet 	  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega as variaveis de impressao                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aSitTrib,"00")
aadd(aSitTrib,"10")
aadd(aSitTrib,"20")
aadd(aSitTrib,"30")
aadd(aSitTrib,"40")
aadd(aSitTrib,"41")
aadd(aSitTrib,"50")
aadd(aSitTrib,"51")
aadd(aSitTrib,"60")
aadd(aSitTrib,"70")
aadd(aSitTrib,"90")
aadd(aSitTrib,"PART")

aadd(aSitSN,"101")
aadd(aSitSN,"102")
aadd(aSitSN,"201")
aadd(aSitSN,"202")
aadd(aSitSN,"500")
aadd(aSitSN,"900")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro Destinatario                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cOrcamento	:= M->LQ_NUM
cCliente 	:= M->LQ_CLIENTE
cLoja		:= M->LQ_LOJA

DadosCli(cCliente,cLoja,@cEndDest,@cBairro,@cCEP,@cMunicipio,@cEstado,@cTelefone,@cInsc)

aDest := {cEndDest,cBairro,Transform(cCEP,"@r 99999-999"),"",cMunicipio,cTelefone,cEstado,cInsc,""}

aAdd(aHrEnt,Time())
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro Faturas                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nFaturas > 0
	For nX := 1 To 3
		aAux := {}
		For nY := 1 To Min(9, nFaturas)
			Do Case
				Case nX == 1
					If nFaturas > 1
						AAdd(aAux, AllTrim(aPgtos[nY][3]))
					Else
						AAdd(aAux, AllTrim(aPgtos[nY][3]))
					EndIf
				Case nX == 2
					If nFaturas > 1
						AAdd(aAux, AllTrim(DTOC(aPgtos[nY][1])))
					Else
						AAdd(aAux, AllTrim(DTOC(aPgtos[nY][1])))
					EndIf
				Case nX == 3
					If nFaturas > 1
						AAdd(aAux, AllTrim(TransForm(aPgtos[nY][2], "@E 9,999,999,999,999.99")))
					Else
						AAdd(aAux, AllTrim(TransForm(aPgtos[nY][2], "@E 9,999,999,999,999.99")))
					EndIf
			EndCase
		Next nY
		If nY <= 9
			For nY := 1 To 9
				AAdd(aAux, Space(20))
			Next nY
		EndIf
		AAdd(aFaturas, aAux)
	Next nX
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro transportadora                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTransp := {"","","","","","","","","","","","","","","",""}

DadosTrans(cCliente,cLoja,@aTransp)

nVolume := 0
if nVolume > 0  
	aTransp[11] := AllTrim(str(nVolume))
endif

nPesoB := 0
if nPesoB > 0 
	aTransp[15] := AllTrim(str(nPesoB))
endif

nPesoL := 0
if nPesoL > 0 
	aTransp[16] := AllTrim(str(nPesoL))
endif

cModFrete := "1"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do Imposto                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTotais 	:= {"","","","","","","","","","",""}
aTotGeral 	:= {0,0,0,0,0,0,0,0,0,0,0}
aSimpNac 	:= {"",""}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro Dados do Produto / Serviço                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosProd 		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2] 
nPosUM 			:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_UM"})][2]
nPosQuant		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_QUANT"})][2]
nPosVlUnit 	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VRUNIT"})][2]
nPosVlItem		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VLRITEM"})][2]
nPosDescri		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_DESCRI"})][2]

nPosTES 		:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_TES"})
nPosCF			:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_CF"})
nPosBaseICM 	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_BASEICM"})
nPosValICM		:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_VALICM"})
nPosValIPI		:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_VALIPI"})

For nX := 1 To Len(aColsDet)

	DbSelectArea( "SB1" )
	DbSetOrder( 1 )
	DbSeek( xFilial("SB1") + aCols[n][nPosProd] )
	
	DbSelectArea( "SF4" )
	DbSetOrder( 1 )
	DbSeek( xFilial("SF4") + aColsDet[nX][nPosTES] )
	
	AAdd( oDet , {aCols[nX][nPosProd],;
					aCols[nX][nPosUM],;
					aCols[nX][nPosQuant],;
					aCols[nX][nPosVlUnit],;
					aCols[nX][nPosVlItem],;
					aColsDet[nX][nPosTES],;
					aColsDet[nX][nPosCF],;
					aCols[nX][nPosDescri],;
					SB1->B1_POSIPI,;
					SB1->B1_ORIGEM+SF4->F4_SITTRIB,;
					aColsDet[nX][nPosBaseICM],;
					aColsDet[nX][nPosValICM],;
					aColsDet[nX][nPosValIPI]})
					
					//CalcImp(cCliente,cLoja,SL2->L2_PRODUTO,SL2->L2_TES,SL2->L2_QUANT,SL2->L2_VRUNIT,"",@aTotGeral)
Next 

aTotais[01] := MaFisRet(,"NF_BASEICM")		
aTotais[02] := MaFisRet(,"NF_VALICM")
aTotais[03] := MaFisRet(,"NF_BASESOL")
aTotais[04] := MaFisRet(,"NF_VALSOL")
aTotais[05] := MafisRet(,"NF_TOTAL")
aTotais[06] := MaFisRet(,"NF_FRETE")
aTotais[07] := MaFisRet(,"NF_SEGURO")
aTotais[08] := MafisRet(,"NF_DESCONTO")
aTotais[09] := MaFisRet(,"NF_DESPESA")
aTotais[10] := MaFisRet(,"NF_VALIPI")
aTotais[11] := MafisRet(,"NF_TOTAL")

aTotais[01] := Transform(aTotais[01]	,"@e 9,999,999,999,999.99")
aTotais[02] := Transform(aTotais[02] 	,"@e 9,999,999,999,999.99")
aTotais[03] := Transform(aTotais[03]	,"@e 9,999,999,999,999.99")
aTotais[04] := Transform(aTotais[04]	,"@e 9,999,999,999,999.99")
aTotais[05] := Transform(aTotais[05]	,"@e 9,999,999,999,999.99")
aTotais[06] := Transform(aTotais[06]	,"@e 9,999,999,999,999.99")
aTotais[07] := Transform(aTotais[07]	,"@e 9,999,999,999,999.99")
aTotais[08] := Transform(aTotais[08]	,"@e 9,999,999,999,999.99")
aTotais[09] := Transform(aTotais[09]	,"@e 9,999,999,999,999.99")
aTotais[10] := Transform(aTotais[10]	,"@e 9,999,999,999,999.99")
aTotais[11] := Transform(aTotais[11]	,"@e 9,999,999,999,999.99")

nLenDet := Len(oDet)

If lMv_ItDesc
	For nX := 1 To nLenDet
		Aadd(aIndAux, {nX, SubStr(NoChar(oDet[nX,1],lConverte),1,MAXITEMC)})
	Next
	
	aIndAux := aSort(aIndAux,,, { |x, y| x[2] < y[2] })
	
	For nX := 1 To nLenDet
		Aadd(aIndImp, aIndAux[nX][1] )
	Next
EndIf

For nZ := 1 To nLenDet

	nQtd     		:= oDet[nZ,3]
	nVUnit   		:= oDet[nZ,4]
	nVTotal  		:= oDet[nZ,5]
	nBaseICM 		:= oDet[nZ,11]									//CalcImp(cCliente,cLoja,oDet[nZ,1],oDet[nZ,6],nQtd,nVUnit,"NF_BASEICM",)
	nValICM  		:= oDet[nZ,12]									//CalcImp(cCliente,cLoja,oDet[nZ,1],oDet[nZ,6],nQtd,nVUnit,"NF_VALICM",)
	nValIPI  		:= oDet[nZ,13]									//CalcImp(cCliente,cLoja,oDet[nZ,1],oDet[nZ,6],nQtd,nVUnit,"NF_VALIPI",)
	nPICM    		:= Int( (oDet[nZ,12]/oDet[nZ,11])*100 )		//CalcImp(cCliente,cLoja,oDet[nZ,1],oDet[nZ,6],nQtd,nVUnit,"IT_ALIQICM",)
	nPIPI    		:= Int( (oDet[nZ,13]/oDet[nZ,11])*100 )		//CalcImp(cCliente,cLoja,oDet[nZ,1],oDet[nZ,6],nQtd,nVUnit,"IT_ALIQIPI",)
	cSitTrib 		:= ""	
	lPontilhado	:= .F.
	
	nMaxCod := MaxCod(oDet[nZ,1], 50)
	
	nMaxCod := 18
	nMaxDes := 23
	
	// Tratamento para quebrar os digitos dos valores
	aAux := {}
	AADD(aAux, AllTrim(TransForm(nQtd		,TM(nQtd		,TamSX3("D2_QUANT")[1]		,TamSX3("D2_QUANT")[2]))))
	AADD(aAux, AllTrim(TransForm(nVUnit		,TM(nVUnit		,TamSX3("D2_PRCVEN")[1]		,TamSX3("D2_PRCVEN")[2]))))
	AADD(aAux, AllTrim(TransForm(nVTotal	,TM(nVTotal	,TamSX3("D2_TOTAL")[1]		,TamSX3("D2_TOTAL")[2]))))
	AADD(aAux, AllTrim(TransForm(nBaseICM	,TM(nBaseICM	,TamSX3("D2_BASEICM")[1]		,TamSX3("D2_BASEICM")[2]))))
	AADD(aAux, AllTrim(TransForm(nValICM	,TM(nValICM	,TamSX3("D2_VALICM")[1]		,TamSX3("D2_VALICM")[2]))))
	AADD(aAux, AllTrim(TransForm(nValIPI	,TM(nValIPI	,TamSX3("D2_VALIPI")[1]		,TamSX3("D2_BASEIPI")[2]))))

	aadd(aItens,{;
			oDet[nZ,1],;
			AllTrim(SubStr(oDet[nZ,8],1,nMaxDes)),;
			oDet[nZ,9],;
			oDet[nZ,10],;
			oDet[nZ,7],;
			oDet[nZ,2],;
			SubStr(aAux[1], 1, PosQuebrVal(aAux[1])),;
			SubStr(aAux[2], 1, PosQuebrVal(aAux[2])),;
			SubStr(aAux[3], 1, PosQuebrVal(aAux[3])),;
			SubStr(aAux[4], 1, PosQuebrVal(aAux[4])),;
			SubStr(aAux[5], 1, PosQuebrVal(aAux[5])),;
			SubStr(aAux[6], 1, PosQuebrVal(aAux[6])),;
			AllTrim(TransForm(nPICM,"@r 99.99%")),;
			AllTrim(TransForm(nPIPI,"@r 99.99%"));
		})
	
	cAuxItem := AllTrim(SubStr(oDet[nZ,1],nMaxCod+1))
	cAux     := AllTrim(SubStr(NoChar(oDet[nZ,8],lConverte),(nMaxDes+1)))
	aAux[1]  := SubStr(aAux[1], PosQuebrVal(aAux[1]) + 1)
	aAux[2]  := SubStr(aAux[2], PosQuebrVal(aAux[2]) + 1)
	aAux[3]  := SubStr(aAux[3], PosQuebrVal(aAux[3]) + 1)
	aAux[4]  := SubStr(aAux[4], PosQuebrVal(aAux[4]) + 1)
	aAux[5]  := SubStr(aAux[5], PosQuebrVal(aAux[5]) + 1)
	aAux[6]  := SubStr(aAux[6], PosQuebrVal(aAux[6]) + 1)

	While !Empty(cAux) .Or. !Empty(cAuxItem) .Or. !Empty(aAux[1]) .Or. !Empty(aAux[2]) .Or. !Empty(aAux[3]) .Or. !Empty(aAux[4]) .Or. !Empty(aAux[5]) .Or. !Empty(aAux[6])
		nMaxCod := MaxCod(cAuxItem, 50)
		
		aadd(aItens,{;
			SubStr(cAuxItem,1,nMaxCod),;
			SubStr(cAux,1,nMaxDes),;
			"",;
			"",;
			"",;
			"",;
			SubStr(aAux[1], 1, PosQuebrVal(aAux[1])),;
			SubStr(aAux[2], 1, PosQuebrVal(aAux[2])),;
			SubStr(aAux[3], 1, PosQuebrVal(aAux[3])),;
			SubStr(aAux[4], 1, PosQuebrVal(aAux[4])),;
			SubStr(aAux[5], 1, PosQuebrVal(aAux[5])),;
			SubStr(aAux[6], 1, PosQuebrVal(aAux[6])),;
			"",;
			"";
		})
		
		// Popula as informações para as próximas linhas adicionais
		cAux        := SubStr(cAux,(nMaxDes+1))
		cAuxItem    := SubStr(cAuxItem,nMaxCod+1)
		aAux[1]     := SubStr(aAux[1], PosQuebrVal(aAux[1]) + 1)
		aAux[2]     := SubStr(aAux[2], PosQuebrVal(aAux[2]) + 1)
		aAux[3]     := SubStr(aAux[3], PosQuebrVal(aAux[3]) + 1)
		aAux[4]     := SubStr(aAux[4], PosQuebrVal(aAux[4]) + 1)
		aAux[5]     := SubStr(aAux[5], PosQuebrVal(aAux[5]) + 1)
		aAux[6]     := SubStr(aAux[6], PosQuebrVal(aAux[6]) + 1)
		lPontilhado := .T.	
	EndDo
	
	If lPontilhado
		aadd(aItens,{;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-";
		})
	EndIf

Next nZ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro ISSQN                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aISSQN := {"","","",""}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro de informacoes complementares                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDhCont:= ""
cXJust := ""

aMensagem := {}
cAux := "DANFE emitida no ambiente de homologação - SEM VALOR FISCAL"
While !Empty(cAux)
	aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
	cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
EndDo

For Nx := 1 to Len(aMensagem)
	NoChar(aMensagem[Nx],lConverte)
Next

//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//³Quadro "RESERVADO AO FISCO"                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aResFisco := {}
nBaseIcm  := 0
       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do numero de folhas                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
nFolhas	  := 1
nLenItens := Len(aItens) - MAXITEM // Todos os produtos/serviços excluindo a primeira página
nMsgCompl := Len(aMensagem) - MAXMSG // Todas as mensagens complementares excluindo a primeira página
lFlag     := .T.
While lFlag
	// Caso existam produtos/serviços e mensagens complementares a serem escritas
	If nLenItens > 0 .And. nMsgCompl > 0
		nFolhas++
		// Se estiver habilitado frente e verso e for uma página impar
		If MV_PAR05 == 1 .And. (nFolhas % 2) == 0
			nLenItens -= MAXITEMP3
		Else
			nLenItens -= MAXITEMP2
			nMsgCompl -= MAXMSG
		EndIf
	// Caso existam apenas mensagens complementares a serem escritas
	ElseIf nLenItens <= 0 .And. nMsgCompl > 0
		nFolhas++
		nMsgCompl := 0
	// Caso existam apenas produtos/serviços a serem escritos
	ElseIf nLenItens > 0 .And. nMsgCompl <= 0
		nFolhas++
		// Se estiver habilitado frente e verso e for uma página impar
		If MV_PAR05 == 1 .And. (nFolhas % 2) == 0
			nLenItens -= MAXITEMP3
		Else
			nLenItens -= MAXITEMP2F
		EndIf
	// Se não tiver mais nada a ser escrito fecha a contagem
	Else
		lFlag := .F.
	EndIf
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao do objeto grafico                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oDanfe == Nil
	lPreview := .T.
	oDanfe 	:= FWMSPrinter():New("DANFE", IMP_SPOOL)
	oDanfe:SetPortrait()
	oDanfe:Setup()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao da pagina do objeto grafico                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:StartPage()
nHPage := oDanfe:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oDanfe:nVertRes()
nVPage *= (300/PixelY)
nVPage -= VBOX

cSerie	 := "UNI"
SX5->(DbSetOrder(1))
If SX5->( DbSeek(xFilial("SX5") + "01" + cSerie) )			   
	cNumDoc := AllTrim(X5Descri())	//NxtSX5Nota( cSerie )
else
	cNumDoc := "999999"
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao do Box - Recibo de entrega                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Box(000,000,010,501)
oDanfe:Say(006, 002, "RECEBEMOS DE " + Alltrim(SM0->M0_NOMECOM) + " OS PRODUTOS CONSTANTES DA NOTA FISCAL INDICADA AO LADO", oFont07:oFont)
oDanfe:Box(009,000,037,101)
oDanfe:Say(017, 002, "DATA DE RECEBIMENTO", oFont07N:oFont)
oDanfe:Box(009,100,037,500)
oDanfe:Say(017, 102, "IDENTIFICAÇÃO E ASSINATURA DO RECEBEDOR", oFont07N:oFont)
oDanfe:Box(000,500,037,603)
oDanfe:Say(007, 542, "NF-e", oFont08N:oFont)
oDanfe:Say(017, 510, "N. "+cNumDoc, oFont08:oFont)
oDanfe:Say(027, 510, "SÉRIE "+cSerie, oFont08:oFont)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 1 IDENTIFICACAO DO EMITENTE                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Box(042,000,137,250)
oDanfe:Say(052,098, "Identificação do emitente",oFont12N:oFont)
nLinCalc	:=	065
cStrAux		:=	Alltrim(SM0->M0_NOMECOM)
nForTo		:=	Len(cStrAux)/25
nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
For nX := 1 To nForTo
	oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*25)+1),25), oFont12N:oFont )
	nLinCalc+=10
Next nX

cStrAux		:=	Alltrim(SM0->M0_ENDCOB)+", " + Alltrim(SM0->M0_COMPCOB)
nForTo		:=	Len(cStrAux)/40 
nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
For nX := 1 To nForTo
	oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
	nLinCalc+=10
Next nX

oDanfe:Say(nLinCalc,098, "Cep: " + TransForm(SM0->M0_CEPCOB,"@r 99999-999"),oFont08N:oFont)
nLinCalc+=10
oDanfe:Say(nLinCalc,098, Alltrim(SM0->M0_CIDCOB)+"/"+SM0->M0_ESTCOB,oFont08N:oFont)
nLinCalc+=10
oDanfe:Say(nLinCalc,098, "Fone: " + Alltrim(SM0->M0_TEL),oFont08N:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 2                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Box(042,248,137,351)
oDanfe:Say(055,275, "DANFE",oFont18N:oFont)
oDanfe:Say(065,258, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
oDanfe:Say(075,258, "NOTA FISCAL ELETRÔNICA",oFont07:oFont)
oDanfe:Say(085,266, "0-ENTRADA",oFont08:oFont)
oDanfe:Say(095,266, "1-SAÍDA"  ,oFont08:oFont)
oDanfe:Box(078,315,095,325)
oDanfe:Say(089,318, "1",oFont08N:oFont)
oDanfe:Say(110,255,"N. "+cNumDoc,oFont10N:oFont)
oDanfe:Say(120,255,"SÉRIE "+cSerie,oFont10N:oFont)
oDanfe:Say(130,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenchimento do Array de UF                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"EX","99"})

nHPage := oDanfe:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oDanfe:nVertRes()
nVPage *= (300/PixelY)
nVPage -= VBOX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Logotipo                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMv_Logod
	cGrpCompany:= AllTrim(FWGrpCompany())
	cCodEmpGrp	:= AllTrim(FWCodEmp())
	cUnitGrp	:= AllTrim(FWUnitBusiness())
	cFilGrp		:= AllTrim(FWFilial())

	If !Empty(cUnitGrp)
		cDescLogo	:= cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp
	Else
		cDescLogo	:= cEmpAnt + cFilAnt
	EndIf

	cLogoD := GetSrvProfString("Startpath","") + "DANFE" + cDescLogo + ".BMP"
	If !File(cLogoD)
		cLogoD	:= GetSrvProfString("Startpath","") + "DANFE" + cEmpAnt + ".BMP"
		If !File(cLogoD)
			lMv_Logod := .F.
		EndIf
	EndIf
EndIf

If nfolha==1
	If lMv_Logod
		oDanfe:SayBitmap(045,001,cLogoD,080,090)
	Else
		oDanfe:SayBitmap(045,001,cLogo,080,090)
	EndIF
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Codigo de barra                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cChaveCont := SL1->L1_KEYNFCE	//"3519 0414 7200 1000 0106 5500 1000 0017 9510 0001 7950"
oDanfe:Box(042,350,088,603)
oDanfe:Box(075,350,110,603)
oDanfe:Say(095,355,cChaveCont,oFont12N:oFont)
oDanfe:Box(105,350,137,603)

If nFolha == 1
	oDanfe:Say(085,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
	nFontSize := 28
	oDanfe:Code128C(072,355,SubStr(cChaveCont,4), nFontSize )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 4                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Box(139,000,162,603)
oDanfe:Box(139,000,162,350)
oDanfe:Say(148,002,"NATUREZA DA OPERAÇÃO",oFont08N:oFont)
oDanfe:Say(158,002,"Venda mercadoria",oFont08:oFont)

oDanfe:Say(148,352,"PROTOCOLO DE AUTORIZAÇÃO DE USO",oFont08N:oFont)
oDanfe:Say(158,354,"",oFont08:oFont)

nFolha++

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 5                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Box(164,000,187,603)
oDanfe:Box(164,000,187,200)
oDanfe:Box(164,200,187,400)
oDanfe:Box(164,400,187,603)
oDanfe:Say(172,002,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
oDanfe:Say(180,002,SM0->M0_INSC,oFont08:oFont)
oDanfe:Say(172,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
oDanfe:Say(180,205,"",oFont08:oFont)
oDanfe:Say(172,405,"CNPJ",oFont08N:oFont)
oDanfe:Say(180,405,TransForm(SM0->M0_CGC,"@r 99.999.999/9999-99"),oFont08:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro destinatário/remetente                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAux := TransForm(SA1->A1_CGC,"@r 99.999.999/9999-99")

oDanfe:Say(195,002,"DESTINATARIO/REMETENTE",oFont08N:oFont)
oDanfe:Box(197,000,217,450)
oDanfe:Say(205,002,"NOME/RAZÃO SOCIAL",oFont08N:oFont)
oDanfe:Say(215,002,Alltrim(SA1->A1_NOME),oFont08:oFont)
oDanfe:Box(197,280,217,500)
oDanfe:Say(205,283,"CNPJ/CPF",oFont08N:oFont)
oDanfe:Say(215,283,cAux,oFont08:oFont)

oDanfe:Box(217,000,237,500)
oDanfe:Box(217,000,237,260)
oDanfe:Say(224,002,"ENDEREÇO",oFont08N:oFont)
oDanfe:Say(234,002,aDest[01],oFont08:oFont)
oDanfe:Box(217,230,237,380)
oDanfe:Say(224,232,"BAIRRO/DISTRITO",oFont08N:oFont)
oDanfe:Say(234,232,aDest[02],oFont08:oFont)
oDanfe:Box(217,380,237,500)
oDanfe:Say(224,382,"CEP",oFont08N:oFont)
oDanfe:Say(234,382,aDest[03],oFont08:oFont)

oDanfe:Box(236,000,257,500)
oDanfe:Box(236,000,257,180)
oDanfe:Say(245,002,"MUNICIPIO",oFont08N:oFont)
oDanfe:Say(255,002,aDest[05],oFont08:oFont)
oDanfe:Box(236,150,257,256)
oDanfe:Say(245,152,"FONE/FAX",oFont08N:oFont)
oDanfe:Say(255,152,aDest[06],oFont08:oFont)
oDanfe:Box(236,255,257,341)
oDanfe:Say(245,257,"UF",oFont08N:oFont)
oDanfe:Say(255,257,aDest[07],oFont08:oFont)
oDanfe:Box(236,340,257,500)
oDanfe:Say(245,342,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
oDanfe:Say(255,342,aDest[08],oFont08:oFont)

oDanfe:Box(197,502,217,603)
oDanfe:Say(205,504,"DATA DE EMISSÃO",oFont08N:oFont)
oDanfe:Say(215,504,DTOC(dDatabase),oFont08:oFont)
oDanfe:Box(217,502,237,603)
oDanfe:Say(224,504,"DATA ENTRADA/SAÍDA",oFont08N:oFont)
oDanfe:Say(233,504,DTOC(dDatabase),oFont08:oFont)
oDanfe:Box(236,502,257,603)
oDanfe:Say(243,503,"HORA ENTRADA/SAÍDA",oFont08N:oFont)
oDanfe:Say(252,503,aHrEnt[01],oFont08:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro fatura                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := {{{},{},{},{},{},{},{},{},{}}}
nY := 0
For nX := 1 To Len(aFaturas)
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][1])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][2])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][3])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][4])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][5])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][6])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][7])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][8])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][9])
	If nY >= 9
		nY := 0
	EndIf
Next nX

oDanfe:Say(263,002,"FATURA",oFont08N:oFont)
oDanfe:Box(265,000,296,068)
oDanfe:Box(265,067,296,134)
oDanfe:Box(265,134,296,202)
oDanfe:Box(265,201,296,268)
oDanfe:Box(265,268,296,335)
oDanfe:Box(265,335,296,403)
oDanfe:Box(265,402,296,469)
oDanfe:Box(265,469,296,537)
oDanfe:Box(265,536,296,603)

nColuna := 002
If Len(aFaturas) >0
	For nY := 1 To 9
		oDanfe:Say(273,nColuna,aAux[1][nY][1],oFont08:oFont)
		oDanfe:Say(281,nColuna,aAux[1][nY][2],oFont08:oFont)
		oDanfe:Say(289,nColuna,aAux[1][nY][3],oFont08:oFont)
		nColuna:= nColuna+67
	Next nY
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do imposto                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Say(305,002,"CALCULO DO IMPOSTO",oFont08N:oFont)
oDanfe:Box(307,000,330,121)
oDanfe:Say(316,002,"BASE DE CALCULO DO ICMS",oFont08N:oFont)
oDanfe:Say(326,002,aTotais[01],oFont08:oFont)
oDanfe:Box(307,120,330,200)
oDanfe:Say(316,125,"VALOR DO ICMS",oFont08N:oFont)
oDanfe:Say(326,125,aTotais[02],oFont08:oFont)
oDanfe:Box(307,199,330,360)
oDanfe:Say(316,200,"BASE DE CALCULO DO ICMS SUBSTITUIÇÃO",oFont08N:oFont)
oDanfe:Say(326,202,aTotais[03],oFont08:oFont)
oDanfe:Box(307,360,330,490)
oDanfe:Say(316,363,"VALOR DO ICMS SUBSTITUIÇÃO",oFont08N:oFont)
oDanfe:Say(326,363,aTotais[04],oFont08:oFont)
oDanfe:Box(307,490,330,603)
oDanfe:Say(316,491,"VALOR TOTAL DOS PRODUTOS",oFont08N:oFont)
oDanfe:Say(327,491,aTotais[05],oFont08:oFont)
oDanfe:Box(330,000,353,110)
oDanfe:Say(339,002,"VALOR DO FRETE",oFont08N:oFont)
oDanfe:Say(349,002,aTotais[06],oFont08:oFont)
oDanfe:Box(330,100,353,190)
oDanfe:Say(339,102,"VALOR DO SEGURO",oFont08N:oFont)
oDanfe:Say(349,102,aTotais[07],oFont08:oFont)
oDanfe:Box(330,190,353,290)
oDanfe:Say(339,194,"DESCONTO",oFont08N:oFont)
oDanfe:Say(349,194,aTotais[08],oFont08:oFont)
oDanfe:Box(330,290,353,415)
oDanfe:Say(339,295,"OUTRAS DESPESAS ACESSÓRIAS",oFont08N:oFont)
oDanfe:Say(349,295,aTotais[09],oFont08:oFont)
oDanfe:Box(330,414,353,500)
oDanfe:Say(339,420,"VALOR DO IPI",oFont08N:oFont)
oDanfe:Say(349,420,aTotais[10],oFont08:oFont)
oDanfe:Box(330,500,353,603)
oDanfe:Say(339,506,"VALOR TOTAL DA NOTA",oFont08N:oFont)
oDanfe:Say(349,506,aTotais[11],oFont08:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transportador/Volumes transportados                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Say(361,002,"TRANSPORTADOR/VOLUMES TRANSPORTADOS",oFont08N:oFont)
oDanfe:Box(363,000,386,603)
oDanfe:Say(372,002,"RAZÃO SOCIAL",oFont08N:oFont)
oDanfe:Say(382,002,aTransp[01],oFont08:oFont)
oDanfe:Box(363,245,386,315)
oDanfe:Say(372,247,"FRETE POR CONTA",oFont08N:oFont)

If cModFrete =="0"
	oDanfe:Say(382,247,"0-EMITENTE",oFont08:oFont)
ElseIf cModFrete =="1"
	oDanfe:Say(382,247,"1-DEST/REM",oFont08:oFont)
ElseIf cModFrete =="2"
	oDanfe:Say(382,247,"2-TERCEIROS",oFont08:oFont)
ElseIf cModFrete =="3"
	oDanfe:Say(382,247,"3-REMETENTE",oFont08:oFont)
ElseIf cModFrete =="4"
	oDanfe:Say(382,247,"4-DESTINATARIO",oFont08:oFont)
ElseIf cModFrete =="9"
	oDanfe:Say(382,247,"9-SEM FRETE",oFont08:oFont)
Else
	oDanfe:Say(382,247,"",oFont08:oFont)
Endif

oDanfe:Box(363,315,386,370)
oDanfe:Say(372,317,"CÓDIGO ANTT",oFont08N:oFont)
oDanfe:Say(382,319,aTransp[03],oFont08:oFont)
oDanfe:Box(363,370,386,490)
oDanfe:Say(372,375,"PLACA DO VEÍCULO",oFont08N:oFont)
oDanfe:Say(382,375,aTransp[04],oFont08:oFont)
oDanfe:Box(363,450,386,510)
oDanfe:Say(372,452,"UF",oFont08N:oFont)
oDanfe:Say(382,452,aTransp[05],oFont08:oFont)
oDanfe:Box(363,510,386,603)
oDanfe:Say(372,512,"CNPJ/CPF",oFont08N:oFont)
oDanfe:Say(382,512,aTransp[06],oFont08:oFont)

oDanfe:Box(385,000,409,603)
oDanfe:Box(385,000,409,241)
oDanfe:Say(393,002,"ENDEREÇO",oFont08N:oFont)
oDanfe:Say(404,002,aTransp[07],oFont08:oFont)
oDanfe:Box(385,240,409,341)
oDanfe:Say(393,242,"MUNICIPIO",oFont08N:oFont)
oDanfe:Say(404,242,aTransp[08],oFont08:oFont)
oDanfe:Box(385,340,409,440)
oDanfe:Say(393,342,"UF",oFont08N:oFont)
oDanfe:Say(404,342,aTransp[09],oFont08:oFont)
oDanfe:Box(385,440,409,603)
oDanfe:Say(393,442,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
oDanfe:Say(404,442,aTransp[10],oFont08:oFont)

oDanfe:Box(408,000,432,603)
oDanfe:Box(408,000,432,101)
oDanfe:Say(418,002,"QUANTIDADE",oFont08N:oFont)
oDanfe:Say(428,002,aTransp[11],oFont08:oFont)
oDanfe:Box(408,100,432,200)
oDanfe:Say(418,102,"ESPECIE",oFont08N:oFont)
oDanfe:Say(428,102,Iif(!Empty(aTransp[12]),aTransp[12],Iif(Len(aEspVol)>0,aEspVol[1][1],"")),oFont08:oFont)
//oDanfe:Say(428,102,aEspVol[1][1],oFont08:oFont)
oDanfe:Box(408,200,432,301)
oDanfe:Say(418,202,"MARCA",oFont08N:oFont)
oDanfe:Say(428,202,aTransp[13],oFont08:oFont)
oDanfe:Box(408,300,432,400)
oDanfe:Say(418,302,"NUMERAÇÃO",oFont08N:oFont)
oDanfe:Say(428,302,aTransp[14],oFont08:oFont)
oDanfe:Box(408,400,432,501)
oDanfe:Say(418,402,"PESO BRUTO",oFont08N:oFont)
oDanfe:Say(428,402,Iif(!Empty(aTransp[15]),aTransp[15],Iif(Len(aEspVol)>0 .And. Val(aEspVol[1][3])>0,Transform(Val(aEspVol[1][3]),"@E 999999.9999"),"")),oFont08:oFont)
oDanfe:Box(408,500,432,603)
oDanfe:Say(418,502,"PESO LIQUIDO",oFont08N:oFont)
oDanfe:Say(428,502,Iif(!Empty(aTransp[16]),aTransp[16],Iif(Len(aEspVol)>0 .And. Val(aEspVol[1][2])>0,Transform(Val(aEspVol[1][2]),"@E 999999.9999"),"")),oFont08:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do ISSQN                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Say(686,000,"CALCULO DO ISSQN",oFont08N:oFont)
oDanfe:Box(688,000,711,151)
oDanfe:Say(696,002,"INSCRIÇÃO MUNICIPAL",oFont08N:oFont)
oDanfe:Say(706,002,aISSQN[1],oFont08:oFont)
oDanfe:Box(688,150,711,301)
oDanfe:Say(696,152,"VALOR TOTAL DOS SERVIÇOS",oFont08N:oFont)
oDanfe:Say(706,152,aISSQN[2],oFont08:oFont)
oDanfe:Box(688,300,711,451)
oDanfe:Say(696,302,"BASE DE CÁLCULO DO ISSQN",oFont08N:oFont)
oDanfe:Say(706,302,aISSQN[3],oFont08:oFont)
oDanfe:Box(688,450,711,603)
oDanfe:Say(696,452,"VALOR DO ISSQN",oFont08N:oFont)
oDanfe:Say(706,452,aISSQN[4],oFont08:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados Adicionais                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Say(719,000,"DADOS ADICIONAIS",oFont08N:oFont)
oDanfe:Box(721,000,865,351)
oDanfe:Say(729,002,"INFORMAÇÕES COMPLEMENTARES",oFont08N:oFont)

nLenMensagens:= Len(aMensagem)
nLin:= 741
nMensagem := 0
For nX := 1 To Min(nLenMensagens, MAXMSG)
	oDanfe:Say(nLin,002,aMensagem[nX],oFont08:oFont)
	nLin:= nLin+10
Next nX
nMensagem := nX

oDanfe:Box(721,350,865,603)
oDanfe:Say(729,352,"RESERVADO AO FISCO",oFont08N:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Logotipo Rodape
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ												
if file(cLogoTotvs) .or. Resource2File ( cLogoTotvs, cStartPath+cLogoTotvs )
	oDanfe:SayBitmap(866,484,cLogoTotvs,120,20)
endif	
				
nLenMensagens:= Len(aResFisco)
nLin:= 741
For nX := 1 To Min(nLenMensagens, MAXMSG)
	oDanfe:Say(nLin,351,aResFisco[nX],oFont08:oFont)
	nLin:= nLin+10
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados do produto ou servico                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := {{{},{},{},{},{},{},{},{},{},{},{},{},{},{}}}
nY := 0
nLenItens := Len(aItens)

For nX :=1 To nLenItens
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][01])
	nY++
	aadd(Atail(aAux)[nY],NoChar(aItens[nX][02],lConverte))
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][03])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][04])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][05])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][06])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][07])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][08])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][09])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][10])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][11])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][12])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][13])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][14])
	If nY >= 14
		nY := 0
	EndIf
Next nX
For nX := 1 To nLenItens
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	If nY >= 14
		nY := 0
	EndIf
	
Next nX

// Popula o array de cabeçalho das colunas de produtos/serviços.
aAuxCabec := {;
	"COD. PROD",;
	"DESCRIÇÃO DO PROD./SERV.",;
	"NCM/SH",;
	IIf( cMVCODREG == "1", "CSOSN","CST" ),;
	"CFOP",;
	"UN",;
	"QUANT.",;
	"V.UNITARIO",;
	"V.TOTAL",;
	"BC.ICMS",;
	"V.ICMS",;
	"V.IPI",;
	"A.ICMS",;
	"A.IPI";
}

// Retorna o tamanho das colunas baseado em seu conteudo
aTamCol := RetTamCol(aAuxCabec, aAux, oDanfe, oFont08:oFont, oFont08N:oFont)

oDanfe:Say(440,002,"DADOS DO PRODUTO / SERVIÇO",oFont08N:oFont)
oDanfe:Box(442,000,678,603)
nAuxH := 0
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[1])
oDanfe:Say(450, nAuxH + 2, "COD. PROD",oFont08N:oFont)
nAuxH += aTamCol[1]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[2])
oDanfe:Say(450, nAuxH + 2, "DESCRIÇÃO DO PROD./SERV.", oFont08N:oFont)
nAuxH += aTamCol[2]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[3])
oDanfe:Say(450, nAuxH + 2, "NCM/SH", oFont08N:oFont)
nAuxH += aTamCol[3]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[4])

If cMVCODREG == "1"
	oDanfe:Say(450, nAuxH + 2, "CSOSN", oFont08N:oFont)
Else
	oDanfe:Say(450, nAuxH + 2, "CST", oFont08N:oFont)
Endif
nAuxH += aTamCol[4]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[5])
oDanfe:Say(450, nAuxH + 2, "CFOP", oFont08N:oFont)
nAuxH += aTamCol[5]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[6])
oDanfe:Say(450, nAuxH + 2, "UN", oFont08N:oFont)
nAuxH += aTamCol[6]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[7])
oDanfe:Say(450, nAuxH + 2, "QUANT.", oFont08N:oFont)
nAuxH += aTamCol[7]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[8])
oDanfe:Say(450, nAuxH + 2, "V.UNITARIO", oFont08N:oFont)
nAuxH += aTamCol[8]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[9])
oDanfe:Say(450, nAuxH + 2, "V.TOTAL", oFont08N:oFont)
nAuxH += aTamCol[9]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[10])
oDanfe:Say(450, nAuxH + 2, "BC.ICMS", oFont08N:oFont)
nAuxH += aTamCol[10]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[11])
oDanfe:Say(450, nAuxH + 2, "V.ICMS", oFont08N:oFont)
nAuxH += aTamCol[11]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[12])
oDanfe:Say(450, nAuxH + 2, "V.IPI", oFont08N:oFont)
nAuxH += aTamCol[12]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[13])
oDanfe:Say(450, nAuxH + 2, "A.ICMS", oFont08N:oFont)
nAuxH += aTamCol[13]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[14])
oDanfe:Say(450, nAuxH + 2, "A.IPI", oFont08N:oFont)

If MV_PAR05=1 .And. nFolhas>1
	oDanfe:Say(875,497,"CONTINUA NO VERSO")
Endif

// INICIANDO INFORMAÇÕES PARA O CABEÇALHO DA PAGINA 2
nLinha	:= 460
nL	:= 0
lFlag	:= .T.

For nY := 1 To nLenItens
	nL++
	
	nLin:= 741
	nCont := 0
	
	If lflag
		If nL > nMaxItemP2
			oDanfe:EndPage()
			oDanfe:StartPage()
			If MV_PAR05 == 1
				nLinhavers := 42
			Else
				nLinhavers := 0
			EndIf		
			nLinha    	:=	181 + IIF(nFolha >=3 ,0, nLinhavers)
			
			oDanfe:Box(000+nLinhavers,000,095+nLinhavers,250)
			oDanfe:Say(010+nLinhavers,098, "Identificação do emitente",oFont12N:oFont)
			
			nLinCalc	:=	023 + nLinhavers
			cStrAux		:=	Alltrim(SM0->M0_NOMECOM)
			nForTo		:=	Len(cStrAux)/25
			nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
			For nX := 1 To nForTo
				oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*25)+1),25), oFont12N:oFont )
				nLinCalc+=10
			Next nX
			
			cStrAux		:=	Alltrim(SM0->M0_ENDCOB)+", " + Alltrim(SM0->M0_COMPCOB)
			nForTo		:=	Len(cStrAux)/40
			nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
			For nX := 1 To nForTo
				oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
				nLinCalc+=10
			Next nX
						
			oDanfe:Say(nLinCalc,098, "Cep: " + TransForm(SM0->M0_CEPCOB,"@r 99999-999"),oFont08N:oFont)
			nLinCalc+=10
			oDanfe:Say(nLinCalc,098, Alltrim(SM0->M0_CIDCOB)+"/"+SM0->M0_ESTCOB,oFont08N:oFont)
			nLinCalc+=10
			oDanfe:Say(nLinCalc,098, "Fone: " + Alltrim(SM0->M0_TEL),oFont08N:oFont)
			
			oDanfe:Box(000+nLinhavers,248,095+nLinhavers,351)
			oDanfe:Say(013+nLinhavers,255, "DANFE",oFont18N:oFont)
			oDanfe:Say(023+nLinhavers,255, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
			oDanfe:Say(033+nLinhavers,255, "NOTA FISCAL ELETRÔNICA",oFont07:oFont)
			oDanfe:Say(043+nLinhavers,255, "0-ENTRADA",oFont08:oFont)
			oDanfe:Say(053+nLinhavers,255, "1-SAÍDA"  ,oFont08:oFont)
			oDanfe:Box(037+nLinhavers,305,047+nLinhavers,315)
			oDanfe:Say(045+nLinhavers,307, "1",oFont08N:oFont)
			oDanfe:Say(062+nLinhavers,255,"N. "+cNumDoc,oFont10N:oFont)
			oDanfe:Say(072+nLinhavers,255,"SÉRIE "+cSerie,oFont10N:oFont)
			oDanfe:Say(082+nLinhavers,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)
			
			oDanfe:Box(000+nLinhavers,350,095+nLinhavers,603)
			oDanfe:Box(000+nLinhavers,350,040+nLinhavers,603)
			oDanfe:Box(040+nLinhavers,350,062+nLinhavers,603)
			oDanfe:Box(063+nLinhavers,350,095+nLinhavers,603)
			oDanfe:Say(058+nLinhavers,355,TransForm(SubStr(cChaveCont,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont12N:oFont)
						
			oDanfe:Say(048+nLinhavers,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
			nFontSize := 28
			oDanfe:Code128C(036+nLinhavers,355,SubStr(cChaveCont,4), nFontSize )
			
			If lMv_Logod
				oDanfe:SayBitmap(002+nLinhavers,003,cLogoD,085,085)
			Else
				oDanfe:SayBitmap(002+nLinhavers,003,cLogo,085,085)
			EndIf
			
			If Empty(cChaveCont)
				oDanfe:Say(075+nLinhavers,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
				oDanfe:Say(085+nLinhavers,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
			Endif
			
			If nFolha == 1
				If !Empty(cCodAutDPEC)
					nFontSize := 28
					oDanfe:Code128C(093+nLinhavers,370,cCodAutDPEC, nFontSize )
				Endif
			Endif
						
			oDanfe:Box(100+nLinhavers,000,123+nLinhavers,603)
			oDanfe:Box(100+nLinhavers,000,123+nLinhavers,300)
			oDanfe:Say(109+nLinhavers,002,"NATUREZA DA OPERAÇÃO",oFont08N:oFont)
			oDanfe:Say(119+nLinhavers,002,"Venda mercadoria",oFont08:oFont)
			
			oDanfe:Say(109+nLinhavers,302,"PROTOCOLO DE AUTORIZAÇÃO DE USO",oFont08N:oFont)
										
			nFolha++
			
			oDanfe:Box(126+nLinhavers,000,153+nLinhavers,603)
			oDanfe:Box(126+nLinhavers,000,153+nLinhavers,200)
			oDanfe:Box(126+nLinhavers,200,153+nLinhavers,400)
			oDanfe:Box(126+nLinhavers,400,153+nLinhavers,603)
			oDanfe:Say(135+nLinhavers,002,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
			oDanfe:Say(143+nLinhavers,002,SM0->M0_INSC,oFont08:oFont)
			oDanfe:Say(135+nLinhavers,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
			oDanfe:Say(143+nLinhavers,205,"",oFont08:oFont)
			oDanfe:Say(135+nLinhavers,405,"CNPJ",oFont08N:oFont)
			oDanfe:Say(143+nLinhavers,405,TransForm(SM0->M0_CGC,"@r 99.999.999/9999-99"),oFont08:oFont)
			
			nLenMensagens:= Len(aMensagem)
			
			nColLim		:=	Iif(MV_PAR05==1,435,Iif(nMensagem <= nLenMensagens,680,865)) + nLinhavers 
			oDanfe:Say(161+nLinhavers,002,"DADOS DO PRODUTO / SERVIÇO",oFont08N:oFont)
			oDanfe:Box(163+nLinhavers,000,nColLim,603)
			
			nAuxH := 0
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[1])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "COD. PROD",oFont08N:oFont)
			nAuxH += aTamCol[1]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[2])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "DESCRIÇÃO DO PROD./SERV.", oFont08N:oFont)
			nAuxH += aTamCol[2]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[3])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "NCM/SH", oFont08N:oFont)
			nAuxH += aTamCol[3]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[4])
			If cMVCODREG == "1"
				oDanfe:Say(171+nLinhavers, nAuxH + 2, "CSOSN", oFont08N:oFont)
			Else
				oDanfe:Say(171+nLinhavers, nAuxH + 2, "CST", oFont08N:oFont)
			Endif
			nAuxH += aTamCol[4]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[5])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "CFOP", oFont08N:oFont)
			nAuxH += aTamCol[5]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[6])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "UN", oFont08N:oFont)
			nAuxH += aTamCol[6]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[7])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "QUANT.", oFont08N:oFont)
			nAuxH += aTamCol[7]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[8])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "V.UNITARIO", oFont08N:oFont)
			nAuxH += aTamCol[8]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[9])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "V.TOTAL", oFont08N:oFont)
			nAuxH += aTamCol[9]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[10])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "BC.ICMS", oFont08N:oFont)
			nAuxH += aTamCol[10]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[11])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "V.ICMS", oFont08N:oFont)
			nAuxH += aTamCol[11]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[12])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "V.IPI", oFont08N:oFont)
			nAuxH += aTamCol[12]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[13])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "A.ICMS", oFont08N:oFont)
			nAuxH += aTamCol[13]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[14])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "A.IPI", oFont08N:oFont)
			
			// FINALIZANDO INFORMAÇÕES PARA O CABEÇALHO DA PAGINA 2
			nL	:= 1
			lFlag	:= .F.                                         		
			
			//Verifico se ainda existem Dados Adicionais a serem impressos
			IF MV_PAR05 <> 1 .And. nMensagem <= nLenMensagens
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Dados Adicionais                                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oDanfe:Say(719+nLinhavers,000,"DADOS ADICIONAIS",oFont08N:oFont)
				oDanfe:Box(721+nLinhavers,000,865+nLinhavers,351)
				oDanfe:Say(729+nLinhavers,002,"INFORMAÇÕES COMPLEMENTARES",oFont08N:oFont)				
				
				nLin:= 741
				nLenMensagens:= Len(aMensagem)
				--nMensagem
				For nX := 1 To Min(nLenMensagens - nMensagem, MAXMSG)
					oDanfe:Say(nLin,002,aMensagem[nMensagem+nX],oFont08:oFont)
					nLin:= nLin+10
				Next nX
				nMensagem := nMensagem+nX
				
				oDanfe:Box(721+nLinhavers,350,865+nLinhavers,603)
				oDanfe:Say(729+nLinhavers,352,"RESERVADO AO FISCO",oFont08N:oFont)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Logotipo Rodape
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ												
				if file(cLogoTotvs) .or. Resource2File ( cLogoTotvs, cStartPath+cLogoTotvs )
					oDanfe:SayBitmap(866,484,cLogoTotvs,120,20)
				endif	
				
				// Seta o máximo de itens para o MAXITEMP2
				nMaxItemP2 := MAXITEMP2
			Else
				// Seta o máximo de itens para o MAXITEMP2F
				nMaxItemP2 := MAXITEMP2F
			EndIF
		Endif		
	Endif
	
	// INICIANDO INFORMAÇÕES PARA O CABEÇALHO DA PAGINA 3 E DIANTE	
	If	nL > Iif( (nfolha-1)%2==0 .And. MV_PAR05==1,MAXITEMP3,nMaxItemP2)
		oDanfe:EndPage()
		oDanfe:StartPage()
		nLenMensagens:= Len(aMensagem)							
		nColLim		:=	Iif(!(nfolha-1)%2==0 .And. MV_PAR05==1,435,Iif(nMensagem <= nLenMensagens,680,865))
		lFimpar		:=  ((nfolha-1)%2==0)
		nLinha    	:=	181      
		If nfolha >= 3
			nLinhavers := 0
		EndIf
		oDanfe:Box(000,000,095,250)
		oDanfe:Say(010,098, "Identificação do emitente",oFont12N:oFont)
		nLinCalc	:=	023
		cStrAux		:=	Alltrim(SM0->M0_NOMECOM)
		nForTo		:=	Len(cStrAux)/25
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*25)+1),25), oFont12N:oFont )
			nLinCalc+=10
		Next nX
		
		cStrAux		:=	Alltrim(SM0->M0_ENDCOB)+", " + Alltrim(SM0->M0_COMPCOB)
		nForTo		:=	Len(cStrAux)/40
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
			nLinCalc+=10
		Next nX		
		oDanfe:Say(nLinCalc,098, "Cep: " + TransForm(SM0->M0_CEPCOB,"@r 99999-999"),oFont08N:oFont)
		nLinCalc+=10
		oDanfe:Say(nLinCalc,098, Alltrim(SM0->M0_CIDCOB)+"/"+SM0->M0_ESTCOB,oFont08N:oFont)
		nLinCalc+=10
		oDanfe:Say(nLinCalc,098, "Fone: " + Alltrim(SM0->M0_TEL),oFont08N:oFont)
		
		oDanfe:Box(000,248,095,351)
		oDanfe:Say(013,255, "DANFE",oFont18N:oFont)
		oDanfe:Say(023,255, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
		oDanfe:Say(033,255, "NOTA FISCAL ELETRÔNICA",oFont07:oFont)
		oDanfe:Say(043,255, "0-ENTRADA",oFont08:oFont)
		oDanfe:Say(053,255, "1-SAÍDA"  ,oFont08:oFont)
		oDanfe:Box(037,305,047,315)
		oDanfe:Say(045,307, "1",oFont08N:oFont)
		oDanfe:Say(062,255, "N. "+cNumDoc,oFont10N:oFont)
		oDanfe:Say(072,255, "SÉRIE "+cSerie,oFont10N:oFont)
		oDanfe:Say(082,255, "FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)
				
		oDanfe:Box(000,350,095,603)
		oDanfe:Box(000,350,040,603)
		oDanfe:Box(040,350,062,603)
		oDanfe:Box(063,350,095,603)
		oDanfe:Say(058,355,,oFont12N:oFont)
		
		oDanfe:Say(048,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
		nFontSize := 28
		oDanfe:Code128C(036,370,SubStr(oNF:_InfNfe:_ID:Text,4), nFontSize )
		
		If lMv_Logod
			oDanfe:SayBitmap(000,000,cLogoD,095,096)
		Else
			oDanfe:SayBitmap(000,000,cLogo,095,096)
		EndIf
		
		If Empty(cChaveCont)
			//oDanfe:Say(075,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
			//oDanfe:Say(085,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
		Endif
				
		If nFolha == 1
			If !Empty(cCodAutDPEC)
				nFontSize := 28
				oDanfe:Code128C(093,370,cCodAutDPEC, nFontSize )
			Endif
		Endif
		
		// inicio do segundo codigo de barras ref. a transmissao CONTIGENCIA OFF LINE
		/*If !Empty(cChaveCont) .And. Empty(cCodAutDPEC) .And. !(Val(SubStr(oNF:_INFNFE:_IDE:_SERIE:TEXT,1,3)) >= 900)
			If nFolha == 1
				If !Empty(cChaveCont)
					nFontSize := 28
					oDanfe:Code128C(093,370,cChaveCont, nFontSize )
				EndIf
			Else
				If !Empty(cChaveCont)
					nFontSize := 28
					oDanfe:Code128C(093,370,cChaveCont, nFontSize )
				EndIf
			EndIf
		EndIf*/
		
		oDanfe:Box(100,000,123,603)
		oDanfe:Box(100,000,123,300)
		oDanfe:Say(109,002,"NATUREZA DA OPERAÇÃO",oFont08N:oFont)
		oDanfe:Say(119,002,"Venda Mercadoria",oFont08:oFont)
		
		oDanfe:Say(109,302,"PROTOCOLO DE AUTORIZAÇÃO DE USO",oFont08N:oFont)		
		oDanfe:Say(119,302,"",oFont08:oFont)

		nFolha++
		
		oDanfe:Box(126,000,153,603)
		oDanfe:Box(126,000,153,200)
		oDanfe:Box(126,200,153,400)
		oDanfe:Box(126,400,153,603)
		oDanfe:Say(135,002,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
		oDanfe:Say(143,002,SM0->M0_INSC,oFont08:oFont)
		oDanfe:Say(135,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
		oDanfe:Say(143,205,"",oFont08:oFont)
		oDanfe:Say(135,405,"CNPJ",oFont08N:oFont)
		oDanfe:Say(143,405,TransForm(SM0->M0_CGC,"@r 99.999.999/9999-99"),oFont08:oFont)
				
		oDanfe:Say(161,002,"DADOS DO PRODUTO / SERVIÇO",oFont08N:oFont)
		oDanfe:Box(163,000,nColLim,603)
		
		nAuxH := 0
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[1])
		oDanfe:Say(171, nAuxH + 2, "COD. PROD",oFont08N:oFont)
		nAuxH += aTamCol[1]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[2])
		oDanfe:Say(171, nAuxH + 2, "DESCRIÇÃO DO PROD./SERV.", oFont08N:oFont)
		nAuxH += aTamCol[2]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[3])
		oDanfe:Say(171, nAuxH + 2, "NCM/SH", oFont08N:oFont)
		nAuxH += aTamCol[3]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[4])
		If cMVCODREG == "1"
			oDanfe:Say(171, nAuxH + 2, "CSOSN", oFont08N:oFont)
		Else
			oDanfe:Say(171, nAuxH + 2, "CST", oFont08N:oFont)
		Endif
		nAuxH += aTamCol[4]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[5])
		oDanfe:Say(171, nAuxH + 2, "CFOP", oFont08N:oFont)
		nAuxH += aTamCol[5]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[6])
		oDanfe:Say(171, nAuxH + 2, "UN", oFont08N:oFont)
		nAuxH += aTamCol[6]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[7])
		oDanfe:Say(171, nAuxH + 2, "QUANT.", oFont08N:oFont)
		nAuxH += aTamCol[7]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[8])
		oDanfe:Say(171, nAuxH + 2, "V.UNITARIO", oFont08N:oFont)
		nAuxH += aTamCol[8]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[9])
		oDanfe:Say(171, nAuxH + 2, "V.TOTAL", oFont08N:oFont)
		nAuxH += aTamCol[9]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[10])
		oDanfe:Say(171, nAuxH + 2, "BC.ICMS", oFont08N:oFont)
		nAuxH += aTamCol[10]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[11])
		oDanfe:Say(171, nAuxH + 2, "V.ICMS", oFont08N:oFont)
		nAuxH += aTamCol[11]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[12])
		oDanfe:Say(171, nAuxH + 2, "V.IPI", oFont08N:oFont)
		nAuxH += aTamCol[12]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[13])
		oDanfe:Say(171, nAuxH + 2, "A.ICMS", oFont08N:oFont)
		nAuxH += aTamCol[13]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[14])
		oDanfe:Say(171, nAuxH + 2, "A.IPI", oFont08N:oFont)
		
		//Verifico se ainda existem Dados Adicionais a serem impressos
		nLenMensagens:= Len(aMensagem)			
		IF (MV_PAR05 <> 1 .Or. (MV_PAR05 == 1 .And. lFimpar )).And. nMensagem <= nLenMensagens
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Dados Adicionais                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oDanfe:Say(719,000,"DADOS ADICIONAIS",oFont08N:oFont)
			oDanfe:Box(721,000,865,351)
			oDanfe:Say(729,002,"INFORMAÇÕES COMPLEMENTARES",oFont08N:oFont)				
			
			nLin:= 741
			nLenMensagens:= Len(aMensagem)
			--nMensagem
			For nX := 1 To Min(nLenMensagens - nMensagem, MAXMSG)				
				oDanfe:Say(nLin,002,aMensagem[nMensagem+nX],oFont08:oFont)
				nLin:= nLin+10
			Next nX
			nMensagem := nMensagem+nX
			
			oDanfe:Box(721+nLinhavers,350,865+nLinhavers,603)
			oDanfe:Say(729+nLinhavers,352,"RESERVADO AO FISCO",oFont08N:oFont)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Logotipo Rodape
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ												
			if file(cLogoTotvs) .or. Resource2File ( cLogoTotvs, cStartPath+cLogoTotvs )
				oDanfe:SayBitmap(866,484,cLogoTotvs,120,20)
			endif	

			// Seta o máximo de itens para o MAXITEMP2
			nMaxItemP2 := MAXITEMP2
		Else
			// Seta o máximo de itens para o MAXITEMP2F
			nMaxItemP2 := MAXITEMP2F
		EndIF	
		If (!(nfolha-1)%2==0) .And. MV_PAR05==1
			If nY+69<nLenItens
				oDanfe:Say(875+nLinhavers,497,"CONTINUA NO VERSO")
			Endif
		End
		
		nL := 1
	EndIf
	
	nAuxH := 0
	
	If aAux[1][1][nY] == "-"
		oDanfe:Say(nLinha, nAuxH, Replicate("- ", 150), oFont08:oFont)
	Else
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][1][nY], oFont08:oFont )
		nAuxH += aTamCol[1]
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][2][nY], oFont08:oFont) // DESCRICAO DO PRODUTO
		nAuxH += aTamCol[2]
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][3][nY], oFont08:oFont) // NCM
		nAuxH += aTamCol[3]
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][4][nY], oFont08:oFont) // CST
		nAuxH += aTamCol[4]
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][5][nY], oFont08:oFont) // CFOP
		nAuxH += aTamCol[5]
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][6][nY], oFont08:oFont) // UN
		nAuxH += aTamCol[6]
		
		nAuxH2 := len(aAux[1][7][nY]) + (nAuxH + (aTamCol[7]) - RetTamTex(aAux[1][7][nY], oFont08:oFont, oDanfe))
		oDanfe:Say(nLinha, nAuxH2, aAux[1][7][nY], oFont08:oFont) // QUANT
		nAuxH += aTamCol[7]		
		
		nAuxH2 := len(aAux[1][8][nY]) + (nAuxH + (aTamCol[8]) - RetTamTex(aAux[1][8][nY], oFont08:oFont, oDanfe))
		oDanfe:Say(nLinha, nAuxH2, aAux[1][8][nY], oFont08:oFont) // V UNITARIO
		nAuxH += aTamCol[8]
		
		nAuxH2 := len(aAux[1][9][nY]) + (nAuxH + (aTamCol[9]) - RetTamTex(aAux[1][9][nY], oFont08:oFont, oDanfe))
		oDanfe:Say(nLinha, nAuxH2, aAux[1][9][nY], oFont08:oFont) // V. TOTAL
		nAuxH += aTamCol[9]
		
		nAuxH2 := len(aAux[1][10][nY]) + (nAuxH + (aTamCol[10]) - RetTamTex(aAux[1][10][nY], oFont08:oFont, oDanfe))
		oDanfe:Say(nLinha, nAuxH2, aAux[1][10][nY], oFont08:oFont) // BC. ICMS
		nAuxH += aTamCol[10]
		
		nAuxH2 := len(aAux[1][11][nY]) + (nAuxH + (aTamCol[11]) - RetTamTex(aAux[1][11][nY], oFont08:oFont, oDanfe))
		oDanfe:Say(nLinha, nAuxH2, aAux[1][11][nY], oFont08:oFont) // V. ICMS
		nAuxH += aTamCol[11]
		
		nAuxH2 := len(aAux[1][12][nY]) + (nAuxH + (aTamCol[12]) - RetTamTex(aAux[1][12][nY], oFont08:oFont, oDanfe))
		oDanfe:Say(nLinha, nAuxH2, aAux[1][12][nY], oFont08:oFont) // V.IPI
		nAuxH += aTamCol[12]
		
		nAuxH2 := len(aAux[1][13][nY]) + (nAuxH + (aTamCol[13]) - RetTamTex(aAux[1][13][nY], oFont08:oFont, oDanfe))
		oDanfe:Say(nLinha, nAuxH2, aAux[1][13][nY], oFont08:oFont) // A.ICMS
		nAuxH += aTamCol[13]
		
		nAuxH2 := len(aAux[1][14][nY]) + (nAuxH + (aTamCol[14]) - RetTamTex(aAux[1][14][nY], oFont08:oFont, oDanfe))
		oDanfe:Say(nLinha, nAuxH2, aAux[1][14][nY], oFont08:oFont) // A.IPI
	EndIf
	
	nLinha :=nLinha + 10
Next nY

nLenMensagens := Len(aMensagem)
While nMensagem <= nLenMensagens
	DanfeCpl(oDanfe,aItens,aMensagem,@nItem,@nMensagem,oNFe,oIdent,oEmitente,@nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,cLogoD,aUF)
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finaliza a Impressão                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPreview
	//oDanfe:Preview()
EndIf
oDanfe:EndPage()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para nao imprimir DANFEs diferentes na mesma folha, uma na FRENTE e outra no VERSO.  |
//|   Isso quando a impressora estiver configurada para frente e verso                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR05==1 .And. MV_PAR01 <> MV_PAR02 .And. (--nFolha)%2<>0
	oDanfe:StartPage()
	oDanfe:EndPage()
EndIf

Return(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impressao do Complemento da NFe                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function DanfeCpl(oDanfe,aItens,aMensagem,nItem,nMensagem,oNFe,oIdent,oEmitente,nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,cLogoD,aUF)
Local nX            := 0
Local nLinha        := 0
Local nLenMensagens := Len(aMensagem)
Local nItemOld	    := nItem
Local nMensagemOld  := nMensagem
Local nForMensagens := 0
Local lMensagens    := .F.
Local cLogo      	:= FisxLogo("1")
Local cChaveCont 	:= ""
Local lConverte     := GetNewPar("MV_CONVERT",.F.)
Local lMv_Logod := If(GetNewPar("MV_LOGOD", "N" ) == "S", .T., .F.   )

Local 	cCNPJCPF :=  ""
Local 	cUF      :=  ""
Local 	cDataEmi :=  ""
Local 	cTPEmis  :=  ""
Local 	cValIcm  :=  ""
Local 	cICMSp   :=  ""
Local 	cICMSs   :=  ""
local cLogoTotvs := "Powered_by_TOTVS.bmp"
local cStartPath := GetSrvProfString("Startpath","")

If (nLenMensagens - (nMensagemOld - 1)) > 0
	lMensagens := .T.
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄ------------------------ÄÄÄÄ¿
//³Dados Adicionais segunda parte em diante³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄ------------------------ÄÄÄÄÙ
If lMensagens
	nLenMensagens := Len(aMensagem)
	nForMensagens := Min(nLenMensagens, MAXITEMP2 + (nMensagemOld - 1) - (nItem - nItemOld))
	oDanfe:EndPage()
	oDanfe:StartPage()
	nLinha    :=180
	oDanfe:Say(160,000,"DADOS ADICIONAIS",oFont08N:oFont)
	oDanfe:Box(172,000,865,351)
	oDanfe:Say(170,002,"INFORMAÇÕES COMPLEMENTARES",oFont08N:oFont)
	oDanfe:Box(172,350,865,603)
	oDanfe:Say(170,352,"RESERVADO AO FISCO",oFont08N:oFont)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Logotipo Rodape
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ												
	if file(cLogoTotvs) .or. Resource2File ( cLogoTotvs, cStartPath+cLogoTotvs )
		oDanfe:SayBitmap(866,484,cLogoTotvs,120,20)
	endif	

	oDanfe:Box(000,000,095,250)
	oDanfe:Say(010,098, "Identificação do emitente",oFont12N:oFont)
	nLinCalc	:=	023
	cStrAux		:=	Alltrim(SM0->M0_NOMECOM)
	nForTo		:=	Len(cStrAux)/25
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*25)+1),25), oFont12N:oFont )
		nLinCalc+=10
	Next nX
	
	cStrAux		:=	Alltrim(SM0->M0_ENDCOB)+", " + Alltrim(SM0->M0_COMPCOB)
	nForTo		:=	Len(cStrAux)/40
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
		nLinCalc+=10
	Next nX
	
	oDanfe:Say(nLinCalc,098, "Cep: " + TransForm(SM0->M0_CEPCOB,"@r 99999-999"),oFont08N:oFont)
	nLinCalc+=10
	oDanfe:Say(nLinCalc,098, Alltrim(SM0->M0_CIDCOB)+"/"+SM0->M0_ESTCOB,oFont08N:oFont)
	nLinCalc+=10
	oDanfe:Say(nLinCalc,098, "Fone: " + Alltrim(SM0->M0_TEL),oFont08N:oFont)
	
	oDanfe:Box(000,248,095,351)
	oDanfe:Say(013,255, "DANFE",oFont18N:oFont)
	oDanfe:Say(023,255, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
	oDanfe:Say(033,255, "NOTA FISCAL ELETRÔNICA",oFont07:oFont)
	oDanfe:Say(043,255, "0-ENTRADA",oFont08:oFont)
	oDanfe:Say(053,255, "1-SAÍDA"  ,oFont08:oFont)
	oDanfe:Box(037,305,047,315)
	oDanfe:Say(045,307,"1" ,oFont08N:oFont)
	oDanfe:Say(062,255,"N. "+cNumDoc,oFont10N:oFont)
	oDanfe:Say(072,255,"SÉRIE "+cSerie,oFont10N:oFont)
	oDanfe:Say(082,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)
	
	oDanfe:Box(000,350,095,603)
	oDanfe:Box(000,350,040,603)
	oDanfe:Box(040,350,062,603)
	oDanfe:Box(063,350,095,603)
	oDanfe:Say(058,355,TransForm(SubStr(cChaveCont,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont12N:oFont)
		
	oDanfe:Say(048,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
	nFontSize := 28
	oDanfe:Code128C(036,370,SubStr(cChaveCont,4), nFontSize )
	
	If lMv_Logod
		oDanfe:SayBitmap(000,000,cLogoD,095,096)
	Else
		oDanfe:SayBitmap(000,000,cLogo,095,096)
	EndIf
	
	If Empty(cChaveCont)
		//oDanfe:Say(075,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
		//oDanfe:Say(085,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
	Endif
	
	If  !Empty(cCodAutDPEC)
		//oDanfe:Say(075,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
		//oDanfe:Say(085,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
	Endif
	
	
	If nFolha == 1
		If !Empty(cCodAutDPEC)
			nFontSize := 28
			oDanfe:Code128C(093,370,cCodAutDPEC, nFontSize )
		Endif
	Endif
	
	// inicio do segundo codigo de barras ref. a transmissao CONTIGENCIA OFF LINE
	/*If !Empty(cChaveCont) .And. Empty(cCodAutDPEC) .And. !(Val(SubStr(oNF:_INFNFE:_IDE:_SERIE:TEXT,1,3)) >= 900)
		If nFolha == 1
			If !Empty(cChaveCont)
				nFontSize := 28
				oDanfe:Code128C(093,370,cChaveCont, nFontSize )
			EndIf
		Else
			If !Empty(cChaveCont)
				nFontSize := 28
				oDanfe:Code128C(093,370,cChaveCont, nFontSize )
			EndIf
		EndIf
	EndIf*/
	
	oDanfe:Box(100,000,123,603)
	oDanfe:Box(100,000,123,300)
	oDanfe:Say(109,002,"NATUREZA DA OPERAÇÃO",oFont08N:oFont)
	oDanfe:Say(119,002,"Venda mercadoria",oFont08:oFont)
	
	oDanfe:Say(109,302,"PROTOCOLO DE AUTORIZAÇÃO DE USO",oFont08N:oFont)
	oDanfe:Say(119,302,"",oFont08:oFont)

	nFolha++
	
	oDanfe:Box(126,000,153,603)
	oDanfe:Box(126,000,153,200)
	oDanfe:Box(126,200,153,400)
	oDanfe:Box(126,400,153,603)
	oDanfe:Say(135,002,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
	oDanfe:Say(143,002,,oFont08:oFont)
	oDanfe:Say(135,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
	oDanfe:Say(143,205,,oFont08:oFont)
	oDanfe:Say(135,405,"CNPJ",oFont08N:oFont)
	oDanfe:Say(143,405,,oFont08:oFont)
	
	For nX := nMensagem To nForMensagens
		oDanfe:Say(nlinha,002,aMensagem[nX],oFont08:oFont)
		nMensagem++
		nLinha:= nLinha+ 10
	Next nX
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finalizacao da pagina do objeto grafico                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:EndPage()

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DANFE     ºAutor  ³Marcos Taranta      º Data ³  10/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pega uma posição (nTam) na string cString, e retorna o      º±±
±±º          ³caractere de espaço anterior.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EspacoAt(cString, nTam)

Local nRetorno := 0
Local nX       := 0

/**
* Caso a posição (nTam) for maior que o tamanho da string, ou for um valor
* inválido, retorna 0.
*/
If nTam > Len(cString) .Or. nTam < 1
	nRetorno := 0
	Return nRetorno
EndIf

/**
* Procura pelo caractere de espaço anterior a posição e retorna a posição
* dele.
*/
nX := nTam
While nX > 1
	If Substr(cString, nX, 1) == " "
		nRetorno := nX
		Return nRetorno
	EndIf
	
	nX--
EndDo

/**
* Caso não encontre nenhum caractere de espaço, é retornado 0.
*/
nRetorno := 0

Return nRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DANFE     ºAutor  ³Fabio Santana	     º Data ³  04/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Converte caracteres espceiais						          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
STATIC FUNCTION NoChar(cString,lConverte)

Default lConverte := .F.

If lConverte
	cString := (StrTran(cString,"&lt;","<"))
	cString := (StrTran(cString,"&gt;",">"))
	cString := (StrTran(cString,"&amp;","&"))
	cString := (StrTran(cString,"&quot;",'"'))
	cString := (StrTran(cString,"&#39;","'"))
EndIf

Return(cString)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DANFEIII  ºAutor  ³Microsiga           º Data ³  12/17/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tratamento para o código do item                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION MaxCod(cString,nTamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para saber quantos caracteres irão caber na linha ³
//³ visto que letras ocupam mais espaço do que os números.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local nMax	:= 0
Local nY   	:= 0
Default nTamanho := 45

For nMax := 1 to Len(cString)
	If IsAlpha(SubStr(cString,nMax,1)) .And. SubStr(cString,nMax,1) $ "MOQW"  // Caracteres que ocupam mais espaço em pixels
		nY += 7
	Else
		nY += 5
	EndIf
	
	If nY > nTamanho   // é o máximo de espaço para uma coluna
		nMax--
		Exit
	EndIf
Next

Return nMax

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetTamCol
Retorna um array do mesmo tamanho do array de entrada, contendo as
medidas dos maiores textos para cálculo de colunas.

@author Marcos Taranta
@since 24/05/2011
@version 1.0 

@param  aCabec     Array contendo as strings de cabeçalho das colunas
        aValores   Array contendo os valores que serão populados nas
                   colunas.
        oPrinter   Objeto de impressão instanciado para utilizar o método
                   nativo de cálculo de tamanho de texto.
        oFontCabec Objeto da fonte que será utilizada no cabeçalho.
        oFont      Objeto da fonte que será utilizada na impressão.

@return aTamCol  Array contendo os tamanhos das colunas baseados nos
                 valores.
/*/
//-----------------------------------------------------------------------
Static Function RetTamCol(aCabec, aValores, oPrinter, oFontCabec, oFont)
	
	Local aTamCol    := {}
	Local nAux       := 0

	Local nX         := 0
	Local nY         := 0
	                          
	Local oFontSize	 := FWFontSize():new()
	
	For nX := 1 To Len(aCabec)
		
		AADD(aTamCol, {})
		aTamCol[nX] := Round(oPrinter:GetTextWidth(aCabec[nX], oFontCabec) * nConsNeg + 4, 0)
		//aTamCol[nX] := oFontSize:getTextWidth( alltrim(aCabec[nX]), oFontCabec:Name, oFontCabec:nWidth, oFontCabec:Bold, oFontCabec:Italic )
		
	Next nX
	
	For nX := 1 To Len(aValores[1])
		
		nAux := 0
		
		For nY := 1 To Len(aValores[1][nX])
			
			If (oPrinter:GetTextWidth(aValores[1][nX][nY], oFont) * nConsTex) > nAux
					nAux := Round(oPrinter:GetTextWidth(aValores[1][nX][nY], oFont) * nConsTex + 4, 0)
					//nAux := oFontSize:getTextWidth( Alltrim(aValores[1][nX][nY]), oFontCabec:Name, oFontCabec:nWidth, oFontCabec:Bold, oFontCabec:Italic )
			EndIf
			
		Next nY
		
		If aTamCol[nX] < nAux
			aTamCol[nX] := nAux
		EndIf
		
	Next nX
	
	// Checa se os campos completam a página, senão joga o resto na coluna da
	//   descrição de produtos/serviços
	nAux := 0
	For nX := 1 To Len(aTamCol)
		
		nAux += aTamCol[nX]
		
	Next nX
	If nAux < 603
		aTamCol[2] += 603 - nAux
	EndIf                       
	If nAux > 603               
		aTamCol[2] -= nAux - 603 
	EndIf

Return aTamCol

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetTamTex
Retorna o tamanho em pixels de uma string. (Workaround para o GetTextWidth)

@author Marcos Taranta
@since 24/05/2011
@version 1.0 

@param  cTexto   Texto a ser medido.
        oFont    Objeto instanciado da fonte a ser utilizada.
        oPrinter Objeto de impressão instanciado.

@return nTamanho Tamanho em pixels da string.
/*/
//-----------------------------------------------------------------------
Static Function RetTamTex(cTexto, oFont, oPrinter)
	  	
	Local nTamanho := 0
	Local oFontSize:= FWFontSize():new() 
	
	//nTamanho := oPrinter:GetTextWidth(cTexto, oFont)
	nTamanho := oFontSize:getTextWidth( cTexto, oFont:Name, oFont:nWidth, oFont:Bold, oFont:Italic )
	
  	nTamanho := Round(nTamanho, 0)
	
Return nTamanho

//-----------------------------------------------------------------------
/*/{Protheus.doc} PosQuebrVal
Retorna a posição onde um valor deve ser quebrado

@author Marcos Taranta
@since 27/05/2011
@version 1.0 

@param  cTexto Texto a ser medido.

@return nPos   Posição aonde o valor deve ser quebrado.
/*/
//-----------------------------------------------------------------------
Static Function PosQuebrVal(cTexto)
	
	Local nPos := 0
	
	If Empty(cTexto)
		Return 0
	EndIf
	
	If Len(cTexto) <= MAXVALORC
		Return Len(cTexto)
	EndIf
	
	If SubStr(cTexto, MAXVALORC, 1) $ ",."
		nPos := MAXVALORC - 2
	Else
		nPos := MAXVALORC
	EndIf
	
Return nPos

static Function ImpItem(oDanfe, aItens, nFolha, nFolhas ,nItem ,nLinha, aTamCol)

local nAuxH 		:= 0


if aAux[1][1][nItem] == "-"
	oDanfe:Say(nLinha, nAuxH, Replicate("- ", 150), oFont08:oFont)
else    
	oDanfe:Say(nLinha, nAuxH + 2, aAux[1][1][nItem], oFont08:oFont) // DESCRICAO DO PRODUTO
	nAuxH += aTamCol[1]
	
	oDanfe:Say(nLinha, nAuxH + 2, aAux[1][2][nItem], oFont08:oFont) // UN
	nAuxH += aTamCol[2]
	
	oDanfe:Say(nLinha, nAuxH + 2, aAux[1][3][nItem], oFont08:oFont) // QUANT
	nAuxH += aTamCol[3]
	
	oDanfe:Say(nLinha, nAuxH + 2, aAux[1][4][nItem], oFont08:oFont) // V UNITARIO
	nAuxH += aTamCol[4]
	
	oDanfe:Say(nLinha, nAuxH + 2, aAux[1][5][nItem], oFont08:oFont) // V. TOTAL
endif
	

return(.T.)
       			                                                                                 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finalizacao da pagina do objeto grafico                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

static Function RiscaItem( oDanfe, nFolha, nFolhas, aTamCol ) 

local lUltFolha		:= .F.
local lFrentVers	:= .F. 
local lFirsFolha	:= nFolha == 1
local nAuxH			:= 0

//Declara onde inicia as linhas dos quadros dos itens e dos Says de cada quadro, 
//os valores padrões são para a primeira pagina com Danfe de apenas 1 pagina.
local nRow1			:= 277 //Linha dos Box's 
local nRow2			:= 284 //Linha dos Say's 

//Declara a altura dos quadros dos itens, o valor padrão é para a primeira 
//página com DANFE de apenas 1 pagina
local nAlt1			:= 843   


if MV_PAR05 == 1
	lFrentVers := .T.	
endif             
if nFolhas == nFolha
	lUltFolha	:= .T.	
endif

if nFolha ==1	
	oDanfe:Say(275,002,"DADOS DO PRODUTO / SERVIÇO",oFont08N:oFont)
	oDanfe:Box(277,000,678,603)
	if !lUltFolha
		nAlt1 := 865	
	endif
elseif nFolhas > 1  .And. nFolha <> 1 
	if lFrentVers .And. nFolha == 2		
		nRow1	:= 042  
		nRow2	:= 052
		if !lUltFolha
			nAlt1	:= 865	
		endif			
		//oDanfe:Box(042,000,147,250)
	else
		nRow1	:= 000  
		nRow2	:= 010
		if !lUltFolha
			nAlt1	:= 865	
		endif			
		//oDanfe:Box(042,000,147,250)						
	endif		
else	
	
endif	
nAuxH := 0
oDanfe:Box(nRow1, nAuxH, nAlt1, nAuxH + aTamCol[1])
if lFirsFolha
	oDanfe:Say(nRow2, nAuxH + 2, "DESCRIÇÃO DO PROD./SERV.", oFont08N:oFont)
endif	
nAuxH += aTamCol[1]
oDanfe:Box(nRow1, nAuxH, nAlt1, nAuxH + aTamCol[2])
if lFirsFolha
	oDanfe:Say(nRow2, nAuxH + 2, "UN", oFont08N:oFont)
endif	
nAuxH += aTamCol[2]
oDanfe:Box(nRow1, nAuxH, nAlt1, nAuxH + aTamCol[3])
if lFirsFolha
	oDanfe:Say(nRow2, nAuxH + 2, "QUANT.", oFont08N:oFont)
endif	
nAuxH += aTamCol[3]
oDanfe:Box(nRow1, nAuxH, nAlt1, nAuxH + aTamCol[4])
if lFirsFolha
	oDanfe:Say(nRow2, nAuxH + 2, "V.UNITARIO", oFont08N:oFont)
endif	
nAuxH += aTamCol[4]
oDanfe:Box(nRow1, nAuxH, nAlt1, nAuxH + aTamCol[5])
if lFirsFolha
	oDanfe:Say(nRow2, nAuxH + 2, "V.TOTAL", oFont08N:oFont)
endif	

return(.T.)

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 22/05/2019
@Hora: 18:27:34
@Versão: 1.0
@Uso: 
@Descrição: 
--------------------------------------------*/
Static Function DadosCli(cCliente,cLoja,cEndDest,cBairro,cCEP,cMunicipio,cEstado,cTelefone,cInsc)

	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1") + cCliente + cLoja ))
	
	cEndDest 	:= SA1->A1_END 
	cBairro		:= SA1->A1_BAIRRO
	cCEP		:= SA1->A1_CEP
	cMunicipio	:= SA1->A1_MUN
	cEstado		:= SA1->A1_EST
	cTelefone	:= SA1->A1_TEL
	cInsc		:= SA1->A1_INSCR

Return Nil

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 23/05/2019
@Hora: 09:10:12
@Versão: 1.0
@Uso: 
@Descrição: 
---------------------------------------------
Change:
--------------------------------------------*/
Static function DadosTrans(cCliente,cLoja,aTransp)

	Local cTransp	:= ""

	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1") + cCliente + cLoja ))
	
	if !Empty(SL1->L1_TRANSP)
		cTransp := SL1->L1_TRANSP
	
	Elseif !Empty(SA1->A1_TRANSP)
		cTransp := SA1->A1_TRANSP
	
	Endif

	SA4->(DbSetOrder(1))
	if SA4->(DbSeek(xFilial("SA4") + cTransp ))
				
		aTransp[01] 	:= NoChar(SA4->A4_NOME)
		aTransp[03] 	:= ""
		aTransp[04] 	:= ""
		aTransp[05] 	:= SA4->A4_EST
		aTransp[06] 	:= Transform(SA4->A4_CGC,"@r 99.999.999/9999-99")
		aTransp[07] 	:= NoChar(SA4->A4_END)
		aTransp[08] 	:= SA4->A4_MUN
		aTransp[09] 	:= SA4->A4_EST
		aTransp[10] 	:= SA4->A4_INSEST
		aTransp[12] 	:= ""		//Especie
		aTransp[13]	:= ""		//Marca
		aTransp[14] 	:= ""
		
	endif
		
Return Nil

/*--------------------------------------------
@Autor: Eduardo Patriani
@Data: 23/05/2019
@Hora: 15:04:18
@Versão: 1.0
@Uso: 
@Descrição: 
---------------------------------------------
Change:
--------------------------------------------*/
Static function CalcImp(cCliente,cLoja,cProduto,cTES,nQuant,nPreco,cTpImp,aTotais)

	Local aArea 		:= GetArea()

	Local aRelImp		:= MaFisRelImp("MT100",{"SF2","SD2"})
	
	Local nRetorno		:= 0
	Local nRecno		:= 0
	
	Default cTpImp		:= ""
	Default aTotais	:= {}
	
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1") + cCliente + cLoja ))
	
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1") + AvKey(cProduto,"B1_COD")))
	nRecno := SB1->(Recno())
	
	MaFisEnd()
	
	MaFisIni(	SA1->A1_COD		,;
				SA1->A1_LOJA		,;
				"C"					,;
				"N"					,;
				SA1->A1_TIPO		,;
				aRelImp				,;
									,;
									,;
				"SB1"				,;                 
				"MATA461"			)
	
				
	MaFisAdd(	cProduto,cTES,nQuant,nPreco,0,"","",,0,0,0,0,(nQuant*nPreco),0,nRecno )
	
	if cTpImp == "NF_VALICM"
		nRetorno := MaFisRet(,"NF_VALICM")
				
	elseif cTpImp == "NF_BASEICM"
		nRetorno := MaFisRet(,"NF_BASEICM")
				
	elseif cTpImp == "NF_VALIPI"
		nRetorno := MaFisRet(,"NF_VALIPI")
					
	elseif cTpImp == "NF_BASEIPI"
		nRetorno := MaFisRet(,"NF_BASEIPI")
					
	elseif cTpImp == "NF_VALSOL"
		nRetorno := MaFisRet(,"NF_VALSOL")
					
	elseif cTpImp == "NF_BASESOL"
		nRetorno := MaFisRet(,"NF_BASESOL")
					
	elseif cTpImp == "NF_FRETE"
		nRetorno := MaFisRet(,"NF_FRETE")
					
	elseif cTpImp == "NF_SEGURO"
		nRetorno := MaFisRet(,"NF_SEGURO")
					
	elseif cTpImp == "NF_DESPESA"
		nRetorno := MaFisRet(,"NF_DESPESA")
					
	elseif cTpImp == "NF_TOTAL"
		nRetorno := MaFisRet(,"NF_TOTAL")
		
	elseif cTpImp == "IT_ALIQICM"
		nRetorno := MaFisRet(1,"IT_ALIQICM")
	
	elseif cTpImp == "IT_ALIQIPI"
		nRetorno := MaFisRet(1,"IT_ALIQIPI")
				
	endif
		
	if Len(aTotais) > 0
		aTotais[01] += MaFisRet(,"NF_BASEICM")		
		aTotais[02] += MaFisRet(,"NF_VALICM")
		aTotais[03] += MaFisRet(,"NF_BASESOL")
		aTotais[04] += MaFisRet(,"NF_VALSOL")
		aTotais[05] += MafisRet(,"NF_TOTAL")
		aTotais[06] += MaFisRet(,"NF_FRETE")
		aTotais[07] += MaFisRet(,"NF_SEGURO")
		aTotais[08] += MafisRet(,"NF_DESCONTO")
		aTotais[09] += MaFisRet(,"NF_DESPESA")
		aTotais[10] += MaFisRet(,"NF_VALIPI")
		aTotais[11] += MafisRet(,"NF_TOTAL")
	endif
	MaFisEnd()
			
	RestArea(aArea)
	
Return(nRetorno)