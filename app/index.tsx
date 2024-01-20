import React, { useState } from 'react';
import { StatusBar } from 'expo-status-bar';
import { Text, View, StyleSheet } from 'react-native';
import axios from 'axios';
import RSSParser from 'react-native-rss-parser';
const linkk: string = "https://www.reddit.com/r/jailbreak.rss"
export default function Page() {
    const [rss, setRss] = useState("bruh")
    fetch(linkk)
    .then((response) => response.text())
    .then(async (responseData) => {
        const rss = await RSSParser.parse(responseData);
        // console.log(rss.items)
        setRss(rss)
    });
    return (
    <View style={styles.container}>
        <Text>{rss.title}</Text>
        <Text>{rss.items.content}</Text>
        {/* <Text>{rss.items[0].title}</Text> */}
        {/* <Image source={{uri: rss.items[0].imageUrl}} style={{ width: 100, height: 100 }}/> */}
        <StatusBar style="auto" />
    </View>
    )
}
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});