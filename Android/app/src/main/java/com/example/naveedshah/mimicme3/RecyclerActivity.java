package com.example.naveedshah.mimicme3;

import android.app.Activity;
import android.support.v7.widget.RecyclerView;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;

import android.support.v7.widget.RecyclerView;

import com.example.naveedshah.mimicme3.ChatRoomContent.ChatRoom;

import com.example.naveedshah.mimicme3.ItemFragment.OnListFragmentInteractionListener;

public class RecyclerActivity extends Activity {
    private RecyclerView mRecyclerView;
    private RecyclerView.Adapter mAdapter;
    private RecyclerView.LayoutManager mLayoutManager;
    private ChatRoomContent myChatRoomContent;
    private ItemFragment myItemFragement;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.recycler_view);
        mRecyclerView = (RecyclerView) findViewById(R.id.my_recycler_view);
        // list is the id for fragment_item_list.xml

        // use this setting to improve performance if you know that changes
        // in content do not change the layout size of the RecyclerView
        mRecyclerView.setHasFixedSize(true);

        // use a linear layout manager
        mLayoutManager = new LinearLayoutManager(this);
        mRecyclerView.setLayoutManager(mLayoutManager);

        myChatRoomContent = new ChatRoomContent();
        myItemFragement = new ItemFragment();
        myChatRoomContent.insertDummyData();
        // specify an adapter (see also next example)
        mAdapter = new MyItemRecyclerViewAdapter(myChatRoomContent.ITEMS, myItemFragement.mListener);
        // This is going to be another class
        mRecyclerView.setAdapter(mAdapter);
    }
}
