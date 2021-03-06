/* @flow */
import type { Observable } from 'rxjs'
import { of } from 'rxjs'
import { tap, switchMap } from 'rxjs/operators'

import { PostRequest } from './index'
import { Storage } from '../storage'
import type { Response } from './index'
import type { User } from '../model/user'
import { UserQuery } from './user-query'

type Params = {|
  name: string,
  email: string,
  password: string,
|}

export class SignUpRequest extends PostRequest<Params, User> {
  constructor() {
    super('/account/new')
  }

  send(params: Params): Observable<Response<User, string>> {
    return super.send(params)
      .pipe(
        tap(response => {
          if (response.state === 'retrieved') {
            Storage.store(Storage.Auth, response.value)
          } else if (response.state === 'failed') {
            Storage.remove(Storage.Auth)
            throw response
          }
        }),
        switchMap(response => response.state === 'retrieved'
          ? new UserQuery().send()
          : of(response)
        ),
      )
  }
}
