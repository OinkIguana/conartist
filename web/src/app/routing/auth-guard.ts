import { Injectable, Inject } from '@angular/core';
import { CanActivate, Router } from '@angular/router';
import * as decode from 'jwt-decode';

import BroadcastService from '../broadcast/broadcast.service';
import { SignInEvent } from '../broadcast/event';
import APIService from '../api/api.service';

@Injectable()
export default class AuthGuard implements CanActivate {
  private authorized = false;
  constructor(
    @Inject(APIService) private api: APIService,
    @Inject(Router) private router: Router,
    @Inject(BroadcastService) private broadcast: BroadcastService,
  ) {}

  async canActivate(): Promise<boolean> {
    const token = localStorage.getItem('authtoken');
    try {
      if(!token) { throw new Error('No auth token'); }
      const { exp } = decode(token);
      if(new Date(exp * 1000) < new Date()) {
        return false;
      }

      if(!this.authorized) {
        const newToken = await this.api.reauthorize().toPromise();
        localStorage.setItem('authtoken', newToken);
        this.broadcast.emit(new SignInEvent);
      }
      return this.authorized = true;
    } catch(_) {
      localStorage.removeItem('authtoken');
      this.router.navigate(['sign-in']);
      return this.authorized = false;
    }
  }
}
