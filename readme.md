# PowerBuilder Web Request Objects

This repository contains the objects to make a web request (post or get) and handle the results.
For now, I'm only using the native objects (no Ole object yet). But I'll add the support at a later moment.


## Supported PB versions:
This whole thing was coded using PowerBuilder 10.2.1 (Build 9914), but it also works with PB12.5.
I have no access to a any newer versions, so i cannot guarantee it works, but it should.


## Reposity files:
- request_post_get.pbl: Main PBL. Contains the application, a wrapper for my Dummy API and a tester window.
- request_post_get.pbt: Application Target.
- request_post_get.pbw: Workspace
- rn_web_request.pbl: PBL containing the objects used to make the requests. Thats the PBL you want.
- uo_inet_result.sru: Exported object that handles the result of the request.
- uo_requester.sru: Exported object that handles the requests (both post and get) itself.
- uo_requester.zip: A zip file containing both exported objects. (Just for convenience.)


## How to
### Make GET request with querystring. (Option 1)
```PowerBuilder
//Declaring variables
string ls_method, ls_querystring, ls_url
string ls_result
uo_requester luo_requester

//Initializing
ls_method = "echoargs"
ls_querystring = "?foo=42&bar=code"
luo_requester = create uo_requester

//Setting the base url for all requests.
luo_requester.of_set_base_url("https://raccoon-ninja-dummy-api.herokuapp.com/api/v1/")

//Getting the full URL 
ls_url = luo_requester.of_get_full_url(ls_method + ls_querystring)

//The actual GET request.
ls_result = luo_requester.of_get(ls_url)

//Testing result.
if isNull(ls_result) then
	//Something went wrong.
	
else
	//ls_result contains the returned value of the request.
	
end if

//Destroying object.
destroy luo_requester
```



### Make GET request with querystring. (Option 2)
```PowerBuilder
//Declaring variables
string ls_url
string ls_result
uo_requester luo_requester

//Initializing
luo_requester = create uo_requester

//Defining the full URL 
ls_url = "https://raccoon-ninja-dummy-api.herokuapp.com/api/v1/echoargs?foo=42&bar=code"

//The actual GET request.
ls_result = luo_requester.of_get(ls_url)

//Testing result.
if isNull(ls_result) then
	//Something went wrong.
	
else
	//ls_result contains the returned value of the request.
	
end if

//Destroying object.
destroy luo_requester
```



### Make POST request.
```PowerBuilder
//Declaring variables
string ls_headers
string ls_url
string ls_data
string ls_result
blob lblb_data
long ll_data_size
uo_requester luo_requester

//Initializing
luo_requester = create uo_requester

//Defining the full URL 
ls_url = "https://raccoon-ninja-dummy-api.herokuapp.com/api/v1/echo"

//Preparing data that will be sent
ls_data = "I'll send this to the webservice!"

if luo_requester.of_encode_args(ls_data, lblb_data, ll_data_size) = -1 then
	//Error encoding data.
	return -1
end if

//Getting headers.
ls_headers = luo_requester.of_get_headers(ll_data_size)

//The actual GET request.
ls_result = luo_requester.of_post(ls_url, lblb_data, ls_headers)

//Testing result.
if isNull(ls_result) then
	//Something went wrong.
	
else
	//ls_result contains the returned value of the request.
	
end if

//Destroying object.
destroy luo_requester
```



### More examples
You'll find more examples within the test window and the application function "run_sequential_examples".



## Encapsulating
I recommend looking at the object **uo_dummy_requester** to see how you can use this object  to encapsulate POST/GET requests to a single web service.



## TODO
1. Create an object to make GET/POST requests using ole object.
