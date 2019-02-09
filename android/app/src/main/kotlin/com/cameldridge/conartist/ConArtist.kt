package com.cameldridge.conartist

import android.app.Activity
import android.content.SharedPreferences
import android.os.Bundle
import android.preference.PreferenceManager
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import com.cameldridge.conartist.R.id
import com.cameldridge.conartist.model.Model
import com.cameldridge.conartist.model.User
import com.cameldridge.conartist.scenes.ConventionListFragment
import com.cameldridge.conartist.scenes.SignInFragment
import com.cameldridge.conartist.services.Storage
import com.cameldridge.conartist.services.StorageKey
import com.cameldridge.conartist.services.api.API
import com.cameldridge.conartist.services.api.graphql.query.FullUserQuery
import com.cameldridge.conartist.util.ConArtistFragment
import com.cameldridge.conartist.util.Option
import com.cameldridge.conartist.util.asOption
import com.cameldridge.conartist.util.observe
import com.cameldridge.conartist.util.transaction
import com.google.android.material.appbar.AppBarLayout.Behavior
import io.reactivex.subjects.BehaviorSubject

class ConArtist : AppCompatActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    root = this
    setContentView(R.layout.activity_con_artist)

    Storage.retrieve(StorageKey.AuthToken)?.let {
      API.authtoken = it
      Model.setUser(Storage.retrieve(StorageKey.CurrentUser))
      Model.loadUser()
      supportFragmentManager.transaction {
        replace(id.fragment_container, ConventionListFragment())
      }
    } ?: supportFragmentManager.transaction {
      replace(R.id.fragment_container, SignInFragment())
    }
  }

  companion object {
    lateinit var root: ConArtist

    private lateinit var currentFragment: ConArtistFragment

    fun <T: ConArtistFragment> replace(fragment: T) {
      root.supportFragmentManager.transaction {
        replace(R.id.fragment_container, fragment)
        currentFragment = fragment
      }
    }

    fun <T: ConArtistFragment> push(fragment: T) {
      root.supportFragmentManager.transaction {
        hide(currentFragment)
        add(R.id.fragment_container, fragment)
        currentFragment = fragment
      }
    }

    fun <T: ConArtistFragment> present(fragment: T) {
      root.supportFragmentManager.transaction {
        hide(currentFragment)
        add(R.id.fragment_container, fragment)
        currentFragment = fragment
      }
    }

    fun <T: ConArtistFragment> back() {
      root.supportFragmentManager.popBackStack()
    }

    fun authorize(authtoken: String) {
      API.authtoken = authtoken
      Storage.store(authtoken, StorageKey.AuthToken)
    }
  }
}
