module USignIn exposing (update)
import Http
import Json.Decode as Decode
import Json.Encode as Json

import Model exposing (Model)
import Msg exposing (Msg(..))
import Page exposing (Page(..), SignInPageState)
import Status exposing (Status(..))
import Load
import ConRequest
import LocalStorage

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case model.page of
  SignIn page ->
    case msg of
      -- TODO: make form validation more user friendly
      Email new ->
        ( { model | page = SignIn <| validateForm { page | email = new } }
        , if page.is_sign_in then Cmd.none else checkExistingEmail new )
      DidCheckExistingEmail (Ok (ConRequest.Success False)) ->  (model, Cmd.none)
      DidCheckExistingEmail (Ok _) ->  ({ model | page = SignIn { page | status = Failure "That email is already in use" }}, Cmd.none)
      CEmail new    ->  ({ model | page = SignIn <| validateForm { page | c_email = new } }, Cmd.none)
      Password new  ->  ({ model | page = SignIn <| validateForm { page | password = new } }, Cmd.none)
      CPassword new ->  ({ model | page = SignIn <| validateForm { page | c_password = new } }, Cmd.none)
      Terms terms   ->  ({ model | page = SignIn <| validateForm { page | terms_accepted = terms } }, Cmd.none)
      ToggleSignIn  ->
        ( { model
          | page = SignIn { page
                          | is_sign_in = not page.is_sign_in
                          , c_email = ""
                          , c_password = ""
                          , terms_accepted = False
                          , status = Success "" } }
        , Cmd.none)
      DoSignIn ->
        ( { model | page = SignIn { page | status = Progress 0 } }
        , doSignIn page.email page.password )
      DidSignIn (Ok (ConRequest.Success authtoken)) ->
        let newmodel =
          { model
          | user = { email = page.email, keys = 0, products = [], productTypes = [], prices = [], conventions = [] }
          , authtoken = authtoken
          , page = Dashboard }
        in
          (newmodel
          , Cmd.batch
            [ Load.user newmodel
            , LocalStorage.set ("authtoken", authtoken) ] )
      DidSignIn (Ok (ConRequest.Failure error)) ->
        ( { model | page = SignIn { page | status = Failure error } }
        , Cmd.none )
      DoCreateAccount ->
        let valid = SignIn (validateForm page) in
          case valid of
            SignIn { status } -> case status of
              Success _ ->
                ( { model | page = SignIn { page | status = Progress 0 } }
                , createAccount page.email page.password )
              _ -> ( { model | page = valid }, Cmd.none )
            _ -> ( { model | page = valid }, Cmd.none )
      DidCreateAccount (Ok (ConRequest.Success _)) ->
        ( { model | page = SignIn
            { page
            | status = Success "Account created successfully! Log in to get started"
            , is_sign_in = True } }
        , Cmd.none)
      DidCreateAccount (Ok (ConRequest.Failure reason)) ->
        ( { model | page = SignIn { page | status = Failure reason } } , Cmd.none)
      DidSignIn (Err _) ->
        ({ model | page = SignIn { page | status = Failure "Something went wrong. Try again later!" } }, Cmd.none)
      DidCreateAccount (Err _) ->
        ({ model | page = SignIn { page | status = Failure "Something went wrong. Try again later!" } }, Cmd.none)
      DidCheckExistingEmail (Err _) ->
        ({ model | page = SignIn { page | status = Failure "Something went wrong. Try again later!" } }, Cmd.none)
      _ -> (model, Cmd.none)
  _ -> (model, Cmd.none)

validateForm : SignInPageState -> SignInPageState
validateForm page =
  let { email, c_email, password, c_password, terms_accepted, is_sign_in } = page in
    if is_sign_in then page
    else
      if      email == ""                   then { page | status = Failure "Email cannot be blank" }
      else if not <| c_email == email       then { page | status = Failure "Emails do not match" }
      else if password == ""                then { page | status = Failure "Password cannot be blank" }
      else if not <| c_password == password then { page | status = Failure "Passwords do not match" }
      else if not <| terms_accepted         then { page | status = Failure "Please accept the terms and conditions" }
      else                                       { page | status = Success "" }

checkExistingEmail : String -> Cmd Msg
checkExistingEmail email =
  Http.send DidCheckExistingEmail <| Http.get
    ("/api/account/exists/" ++ email)
    (ConRequest.decode Decode.bool)

doSignIn : String -> String -> Cmd Msg
doSignIn email password =
  Http.send DidSignIn <| Http.post "/api/auth"
      (Http.jsonBody <| Json.object
        [ ("usr", Json.string email)
        , ("psw", Json.string password) ] )
      (ConRequest.decode Decode.string)

createAccount : String -> String -> Cmd Msg
createAccount email password =
  Http.send DidCreateAccount <| Http.post "/api/account/new"
      (Http.jsonBody <| Json.object
        [ ("usr", Json.string email)
        , ("psw", Json.string password) ] )
      (ConRequest.decode <| Decode.succeed ())