import React from "react";
import { mockAxios } from "../axiosMock";
import { categories, appListing } from "./AppMocks";
import { UploadTrackingProvider } from "../../src/contexts/uploadTracking";
import Listing from "../../src/components/apps/listing/Listing";

export default {
    title: "Apps",
};

function ListingTest(props) {
    //Note: the params must exactly with original call made by react-query
    mockAxios.onGet("/api/apps/categories?public=false").reply(200, categories);
    mockAxios
        .onGet(
            "/api/apps/categories/de/af109cb5-f050-41dc-93bd-3500e4f3557c?limit=25&sort-field=name&sort-dir=ASC&offset=0"
        )
        .reply(200, appListing);
    //to print all mock handlers
    // console.log(JSON.stringify(mockAxios.handlers, null, 2));
    return (
        <UploadTrackingProvider>
            <Listing baseId="tableView" />
        </UploadTrackingProvider>
    );
}

export const AppsListingTest = () => {
    return <ListingTest />;
};