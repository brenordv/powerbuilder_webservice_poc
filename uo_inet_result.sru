$PBExportHeader$uo_inet_result.sru
$PBExportComments$Object to hold and process results. https://raccoon.ninja
forward
global type uo_inet_result from internetresult
end type
end forward

global type uo_inet_result from internetresult
end type
global uo_inet_result uo_inet_result

type variables
private string is_result
private encoding ie_encoding = EncodingUTF8!
protectedwrite string is_error
end variables

forward prototypes
public function integer internetdata (blob data)
public subroutine of_set_encoding (encoding p_encoding)
public function string of_get_result ()
end prototypes

public function integer internetdata (blob data);/**
* Função de callback do PB. Ela --NÃO-- precisa ser chamada manualmente. 
* O próprio PB chama ela quando recebe o retorno de uma request HTTP.
* Após a request, deve-se chamar a função of_get_result para obter o resultado.
*
* autor: BrV 29/11/2018
*/
int vli_return
try 
	this.is_result = string(data, this.ie_encoding)
	vli_return = 1
catch (Exception ex)
	this.is_error = ex.getMessage()
	vli_return = -1
end try

return vli_return
end function

public subroutine of_set_encoding (encoding p_encoding);/**
* Define o encoding que será utilizado na processar o retorno da request. 
* Por padrão, utiliza-se o EncodingUTF8!
* autor: BrV 29/11/2018
*/
this.ie_encoding = p_encoding
end subroutine

public function string of_get_result ();/**
* Retorna o resultado obtido no request http.
* autor: BrV 29/11/2018
*/
if right(this.is_result, 1) = "~n" then
	this.is_result = mid(this.is_result, 1, len(this.is_result)-1) 
end if

if left(this.is_result, 1) = '"' and right(this.is_result, 1) = '"' then
	return mid(this.is_result, 2, len(this.is_result)-2)
end if
return this.is_result
end function

on uo_inet_result.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_inet_result.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

