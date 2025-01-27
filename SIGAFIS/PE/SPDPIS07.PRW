#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH"

User Function SPDPIS07()

Local	cFilial		:=	PARAMIXB[1]	//FT_FILIAL
Local	cTpMov		:=	PARAMIXB[2]	//FT_TIPOMOV
Local	cSerie		:=	PARAMIXB[3]	//FT_SERIE
Local	cDoc		:=	PARAMIXB[4]	//FT_NFISCAL
Local	cClieFor	:=	PARAMIXB[5]	//FT_CLIEFOR
Local	cLoja		:=	PARAMIXB[6]	//FT_LOJA
//Local	cItem		:=	PARAMIXB[7]	//FT_ITEM
//Local	cProd		:=	PARAMIXB[8]	//FT_PRODUTO	 	
Local	cConta		:=	""
Local   cCfopS      := ALLTRIM(if(cTpmov="S",POSICIONE("SFT",1,XFILIAL("SFT")+cTpMov+cSerie+cDoc+cClieFor+cLoja,"FT_CFOP"),""))  
Local   cCfopE      := ALLTRIM(if(cTpmov="E",POSICIONE("SFT",1,XFILIAL("SFT")+cTpMov+cSerie+cDoc+cClieFor+cLoja,"FT_CFOP"),""))  
Local   cContaS     :=  if (cTpmov="S",POSICIONE("SFT",1,XFILIAL("SFT")+cTpMov+cSerie+cDoc+cClieFor+cLoja,"FT_CONTA"),"")
Local   cContaE     :=  if (cTpmov="E",POSICIONE("SFT",1,XFILIAL("SFT")+cTpMov+cSerie+cDoc+cClieFor+cLoja,"FT_CONTA"),"") 
Local   cCfopRec    :=  SUPERGETMV('MV_ZZCFREC', .T.,'')//('5102|6102|5405|6108|5114')
Local   cCfopDev    :=  SUPERGETMV('MV_ZZCFDEV', .T.,'') //('1202|2202|1411|2411')      
Local   cCfopExp    :=  SUPERGETMV('MV_ZZCFEXP', .T.,'') //('7102')
//Local   cEspecieE   :=  if (cTpmov="E",POSICIONE("SFT",1,XFILIAL("SFT")+cTpMov+cSerie+cDoc+cClieFor+cLoja,"FT_ESPECIE"),"")  
//Local   cEspecieS   :=  if (cTpmov="S",POSICIONE("SFT",1,XFILIAL("SFT")+cTpMov+cSerie+cDoc+cClieFor+cLoja,"FT_ESPECIE"),"")
Local   cMVCtRec    :=  SUPERGETMV('MV_ZZCTREC', .T.,'')// "311010201" Receita Revenda de Mercadorias 
Local   cMVCtDev    :=  SUPERGETMV('MV_ZZCTDEV', .T.,'')// "311020501" Receita Bruta Internacional         
Local   cMVCtExp    :=  SUPERGETMV('MV_ZZCTEXP', .T.,'')// "311030102" Devoluções de Vendas de Mercadorias
 
	IF cTpMov = "S" .AND. cCfopS $ cCfopRec 
		cConta := cMVCtRec      
	ElseIf cTpMov = "S" .AND. cCfopS $ cCfopExp  
		cConta := cMVCtExp 
	ElseIf cTpMov = "S" .AND. cCfopS <> cCfopRec .AND. cCfopS <> cCfopExp 
	 	cConta := cContaS
	ElseIf cTpMov = "E" .AND. cCfopE $ cCfopDev
	    cConta :=  cMVCtDev   
	ElseIf cTpMov = "E" .AND. cCfopE <> cCfopDev
	    cConta :=  cContaE   
	EndIf
	
Return cConta
