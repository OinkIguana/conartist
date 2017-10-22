package com.cameldridge.conartist

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.support.v4.app.Fragment
import android.support.v4.app.FragmentManager
import android.support.v4.app.FragmentPagerAdapter
import android.support.v7.app.AppCompatActivity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import com.cameldridge.conartist.schema.FullConvention
import com.cameldridge.conartist.schema.ProductType
import kotlinx.android.synthetic.main.activity_convention_mode.*
import kotlinx.android.synthetic.main.fragment_product_type_page.view.*
import kotlin.properties.Delegates

class ConventionModeActivity : AppCompatActivity() {
    private var con: FullConvention by Delegates.notNull()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_convention_mode)

        con = intent.getParcelableExtra(CON)

        supportActionBar?.title = con.name
        viewPager.adapter = SectionsPagerAdapter(supportFragmentManager)
        tabBar.setupWithViewPager(viewPager)
    }

    inner class SectionsPagerAdapter(fm: FragmentManager) : FragmentPagerAdapter(fm) {
        override fun getItem(position: Int): Fragment? =
            when(position) {
                0 -> ProductTypesPage.create(con)
                1 -> RecordsPage.create(con)
                2 -> ChatPage.create(con)
                else -> null
            }

        override fun getPageTitle(position: Int) : CharSequence? =
            when(position) {
                0 -> "Sell"
                1 -> "Records"
                2 -> "Chat"
                else -> null
            }

        override fun getCount() = 3
    }

    companion object {
        private val CON = "con"

        fun newIntent(ctx: Context, con: FullConvention): Intent {
            val intent = Intent(ctx, ConventionModeActivity::class.java)
            intent.putExtra(CON, con)
            return intent
        }
    }

    class ProductTypesPage: Fragment() {
        private var con: FullConvention by Delegates.notNull()
        private var productTypes: ArrayAdapter<ProductType> by Delegates.notNull()

        override fun onCreateView(
            inflater: LayoutInflater,
            container: ViewGroup?,
            savedInstanceState: Bundle?
        ): View {
            val view = inflater.inflate(R.layout.fragment_product_type_page, container, false)
            view.productTypeList.adapter = productTypes
            return view
        }

        override fun onCreate(savedInstanceState: Bundle?) {
            super.onCreate(savedInstanceState)
            con = arguments.getParcelable(CON)
            productTypes = ProductTypeRowListAdapter(activity)
        }

        companion object {
            fun create(con: FullConvention): ProductTypesPage {
                val page = ProductTypesPage()
                page.arguments = Bundle()
                page.arguments.putParcelable(CON, con)
                return page
            }
        }
    }

    class RecordsPage: Fragment() {
        private var con: FullConvention by Delegates.notNull()

        override fun onCreateView(
            inflater: LayoutInflater,
            container: ViewGroup?,
            savedInstanceState: Bundle?
        ): View {
            return inflater.inflate(R.layout.fragment_records_page, container, false)
        }

        override fun onCreate(savedInstanceState: Bundle?) {
            super.onCreate(savedInstanceState)
            con = arguments.getParcelable(CON)
        }

        companion object {
            fun create(con: FullConvention): RecordsPage {
                val page = RecordsPage()
                page.arguments = Bundle()
                page.arguments.putParcelable(CON, con)
                return page
            }
        }
    }

    class ChatPage: Fragment() {
        private var con: FullConvention by Delegates.notNull()

        override fun onCreateView(
            inflater: LayoutInflater,
            container: ViewGroup?,
            savedInstanceState: Bundle?
        ): View {
            return inflater.inflate(R.layout.fragment_chat_page, container, false)
        }

        override fun onCreate(savedInstanceState: Bundle?) {
            super.onCreate(savedInstanceState)
            con = arguments.getParcelable(CON)
        }

        companion object {
            fun create(con: FullConvention): ChatPage {
                val page = ChatPage()
                page.arguments = Bundle()
                page.arguments.putParcelable(CON, con)
                return page
            }
        }
    }
}