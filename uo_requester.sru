$PBExportHeader$uo_requester.sru
$PBExportComments$Object  to make web requests. https://raccoon.ninja
forward
global type uo_requester from nonvisualobject
end type
end forward

global type uo_requester from nonvisualobject
end type
global uo_requester uo_requester

type variables
protectedwrite string is_url_base = "http://localhost/"
protectedwrite string is_error = ""
protectedwrite string is_null
protectedwrite long il_port = 80
private inet i_inet
private encoding i_encoding = EncodingUTF8!
end variables

forward prototypes
private function string of_translate_inet_request_error (readonly integer ai_code)
public function integer of_encode_args (readonly string as_args, ref blob ablb_args, ref long al_args_length)
public function string of_get_full_url (readonly string as_url_method)
public subroutine of_set_base_url (readonly string as_url_base)
private function uo_inet_result of_get_result_object ()
public function string of_post (readonly string as_url, readonly blob ablb_args, readonly string as_header, readonly long al_port)
public function string of_post (readonly string as_url, readonly blob ablb_args, readonly string as_headers)
public function string of_get_headers (readonly long al_content_length, readonly string as_content_type)
public function string of_get_headers (readonly long al_content_length)
public subroutine of_set_default_port (readonly long al_port)
public function string of_get (readonly string as_url)
end prototypes

private function string of_translate_inet_request_error (readonly integer ai_code);/*********************************************************************
** [private] of_translate_inet_request_error
** 
** Translates the return code of inet request's function.
** (getURL or postURL)
** 
** args: 
** [readonly]	integer	ai_code:	return code to be translated.
** return: string with translated message.
**
** author: Breno RdV [12/2018] - https://raccoon.ninja 
*********************************************************************/
choose case ai_code
	case -1
		return "General error. May be something related to the way the result object processes the data received."
	case -2
		return "Invalid URL"
	case -4
		return "Cannot connect to the Internet"
	case -5 
		//PowerBuilder cannot make POST requests to an URL, but it can do GET.
		return "Unsupported secure (HTTPS) connection attempted"
	case -6
		return "Internet request failed"
	case else 
		return "Unmapped return code: " + string(ai_code)
end choose

end function

public function integer of_encode_args (readonly string as_args, ref blob ablb_args, ref long al_args_length);/*********************************************************************
** [public] of_encode_args
** 
** Encodes the arguments the will be sent in the request.
** 
** args: 
** [readonly]	string	as_args:				string with arguments that will be sent in the request.
** [reference]	blob		ablb_args:			will store the encoded arguments.
** [reference]	long		al_args_length:	size of the encoded arguments.
** return: 1 if all is OK. -1 on error.
**
** author: Breno RdV [12/2018] - https://raccoon.ninja 
*********************************************************************/
int li_return

try 
	ablb_args = blob(as_args, this.i_encoding)
	al_args_length = len(ablb_args)
	li_return = 1
catch (Exception ex)
	this.is_error = ex.getMessage()
	li_return = -1
end try

return li_return
end function

public function string of_get_full_url (readonly string as_url_method);/*********************************************************************
** [public] of_get_full_url
** 
** Gets the full URL for the request.
** 
** args: 
** [readonly]	string	as_url_method:	name of the method that will be used.
** return: string with full url.
**
** author: Breno RdV [12/2018] - https://raccoon.ninja 
*********************************************************************/
boolean lb_base_backlash
boolean lb_req_backlash

lb_base_backlash = right(this.is_url_base, 1) = "/"
lb_req_backlash = left(as_url_method, 1) = "/"

if lb_base_backlash and lb_req_backlash then
	//If both the base url and the method have a backlashes, will adjust the url accordingly
	return this.is_url_base + mid(as_url_method, 2)
	
elseif not lb_base_backlash and not lb_req_backlash then
	//If none of them have backlashes.
	return this.is_url_base + "/" + as_url_method
	
else
	//If one of them have a backlash and the other don't.
	return this.is_url_base + as_url_method
end if
end function

public subroutine of_set_base_url (readonly string as_url_base);/*********************************************************************
** [public] of_set_base_url
** 
** Sets the default base url.
** 
** args: 
** [readonly]	string	as_url_base:	base url for the requests.
** return: None
**
** author: Breno RdV [12/2018] - https://raccoon.ninja 
*********************************************************************/
this.is_url_base = as_url_base
end subroutine

private function uo_inet_result of_get_result_object ();/*********************************************************************
** [private] of_get_result_object
** 
** Creates an instance of uo_inet_result, configures and returns it.
** 
** args: None
** return: configured instance of uo_inet_result
**
** author: Breno RdV [12/2018] - https://raccoon.ninja 
*********************************************************************/
uo_inet_result luo_result

luo_result = create uo_inet_result
luo_result.of_set_encoding(this.i_encoding)

return luo_result
end function

public function string of_post (readonly string as_url, readonly blob ablb_args, readonly string as_header, readonly long al_port);/*********************************************************************
** [private] of_post
** 
** Makes a post request.
** 
** args: 
** [readonly]	string	as_url:	url to be used in request
** [readonly]	blob		ablb_args:	encoded args that will be sent in the request.
** [readonly]	string	as_header	string with request header
** [readonly]	long		al_port	port that will be used.
** return: string with result of request (or null if something goes wrong)
**
** author: Breno RdV [12/2018] - https://raccoon.ninja 
*********************************************************************/
uo_inet_result luo_post_result
int li_post_ret

try
	luo_post_result = this.of_get_result_object()
	this.is_error = ""
	
	li_post_ret = this.i_inet.postURL(as_url, ablb_args, as_header, al_port, luo_post_result)

	if li_post_ret <> 1 then
		this.is_error = "PowerBuilder could not handle the request. Here's what happened: ~r~n" + this.of_translate_inet_request_error(li_post_ret)
		if luo_post_result.is_error <> "" then
			this.is_error = this.is_error  + "~r~n" + luo_post_result.is_error
		end if
		return this.is_null
	end if

	return luo_post_result.of_get_result()
finally
	if isValid(luo_post_result) then 	destroy luo_post_result
end try
end function

public function string of_post (readonly string as_url, readonly blob ablb_args, readonly string as_headers);/*********************************************************************
** [private] of_post
** 
** Overlaod of of_post. Will use default port.
** 
** args: 
** [readonly]	string	as_url:		url to be used in request
** [readonly]	blob		ablb_args:	encoded args that will be sent in the request.
** [readonly]	string	as_headers	string with request header
** return: string with request result (or null if something wrong happens).
**
** author: Breno RdV [12/2018] - https://raccoon.ninja 
*********************************************************************/
return this.of_post(as_url, ablb_args, as_headers, this.il_port)
end function

public function string of_get_headers (readonly long al_content_length, readonly string as_content_type);/*********************************************************************
** [public] of_get_headers
** 
** Gets a string with the headers that will be used. So far we're only
** supporting content-length and content-type.
** 
** args: 
** [readonly]	long		al_content_length:	Size of the contents being sent.
** [readonly]	string	as_content_type:		(Optional) content-type of the request.
** return: string with processed headers
**
** author: Breno RdV [12/2018] - https://raccoon.ninja 
*********************************************************************/
string headers[]

headers[1] = "Content-Length: "  + String(al_content_length)

//Adds content-type to the header, if it was informed.
if not isNull(as_content_type) then
	headers[2] = "Content-Type: "+ as_content_type
else
	headers[2] = ""
end if

return headers[1] +"~n" + &
		 headers[2] + "~n~n"
end function

public function string of_get_headers (readonly long al_content_length);/*********************************************************************
** [public] of_get_headers
** 
** Overload of of_get_headers. Will only inform content_length.
** 
** args: 
** [readonly]	long		al_content_length:	Size of the contents being sent.
** return: string with processed headers
**
** author: Breno RdV [12/2018] - https://raccoon.ninja 
*********************************************************************/
return this.of_get_headers(al_content_length, this.is_null)
end function

public subroutine of_set_default_port (readonly long al_port);/*********************************************************************
** [public] of_set_default_port
** 
** Sets the default port number.
** 
** args: 
** [readonly]	long	al_port:	default port that will be used.
** return: None
**
** author: Breno RdV [12/2018] - https://raccoon.ninja 
*********************************************************************/
this.il_port = al_port
end subroutine

public function string of_get (readonly string as_url);/*********************************************************************
** [public] of_get
** 
** Makes a get request.
** There's no HEADERS or PORTs that you can define for Get requests.
** 
** args: 
** [readonly]	string	as_url:	url to be used in request
** return: string with result of request (or null if something goes wrong)
**
** author: Breno RdV [12/2018] - https://raccoon.ninja 
*********************************************************************/
uo_inet_result luo_get_result
int li_get_ret

try
	luo_get_result = this.of_get_result_object()
	this.is_error = ""
	
	li_get_ret = this.i_inet.getURL(as_url, luo_get_result)

	if li_get_ret <> 1 then
		this.is_error = "PowerBuilder could not handle the request (GET).~r~nHere's what happened: ~r~n" + this.of_translate_inet_request_error(li_get_ret)
		if luo_get_result.is_error <> "" then
			this.is_error = this.is_error  + "~r~n" + luo_get_result.is_error
		end if
		return this.is_null
	end if

	return luo_get_result.of_get_result()
finally
	if isValid(luo_get_result) then 	destroy luo_get_result
end try
end function

on uo_requester.create
call super::create
TriggerEvent( this, "constructor" )
end on

on uo_requester.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event constructor;SetNull(this.is_null)
this.i_inet = create inet 
end event

event destructor;destroy this.i_inet
end event

