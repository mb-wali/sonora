/**
 * @author aramsey
 *
 * A component intended to be the parent to the data's table view and
 * thumbnail/tile view.
 */
import React, { useEffect, useState } from "react";

import { formatMessage, withI18N } from "@cyverse-de/ui-lib";
import { TablePagination } from "@material-ui/core";

import Header from "../Header";
import messages from "../messages";
import TableView from "./TableView";
import callApi from "../../../common/callApi";
import UploadDropTarget from "../../uploads/UploadDropTarget";
import { useUploadTrackingState } from "../../../contexts/uploadTracking";

import { camelcaseit } from "../../../common/functions";
import HomeIcon from "@material-ui/icons/Home";
import FolderSharedIcon from "@material-ui/icons/FolderShared";
import GroupIcon from "@material-ui/icons/Group";
import DeleteIcon from "@material-ui/icons/Delete";
import NavigationConstants from "../../layout/NavigationConstants";
import { injectIntl } from "react-intl";
import { useRouter } from "next/router";
import { useUserProfile } from "../../../contexts/userProfile";
import constants from "../../../constants";
import Drawer from "../details/Drawer";

function Listing(props) {
    const router = useRouter();
    const uploadTracker = useUploadTrackingState();
    const [userProfile] = useUserProfile();

    const [isGridView, setGridView] = useState(false);
    const [order, setOrder] = useState("asc");
    const [orderBy, setOrderBy] = useState("name");
    const [selected, setSelected] = useState([]);
    const [lastSelectIndex, setLastSelectIndex] = useState(-1);
    const [page, setPage] = useState(0);
    const [rowsPerPage, setRowsPerPage] = useState(25);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState("");
    const [data, setData] = useState({ total: 0, files: [], folders: [] });
    const [detailsEnabled, setDetailsEnabled] = useState(false);
    const [detailsOpen, setDetailsOpen] = useState(false);
    const [detailsResource, setDetailsResource] = useState(null);
    const [infoTypes, setInfoTypes] = useState([]);

    const [dataRoots, setDataRoots] = useState([]);
    const [userHomePath, setUserHomePath] = useState("");
    const [userTrashPath, setUserTrashPath] = useState("");
    const [sharedWithMePath, setSharedWithMePath] = useState("");
    const [communityDataPath, setCommunityDataPath] = useState("");
    const { baseId, path, handlePathChange, intl } = props;

    // Used to force the data listing to refresh when uploads are completed.
    const uploadsCompleted = uploadTracker.uploads.filter((upload) => {
        return (
            upload.parentPath === path &&
            upload.hasUploaded &&
            !upload.hasErrored
        );
    }).length;

    useEffect(() => {
        setSelected([]);
    }, [path]);

    useEffect(() => {
        if (path) {
            callApi({
                endpoint: `/api/filesystem/paged-directory?path=${path}&limit=${rowsPerPage}&sort-col=${orderBy}&sort-dir=${order}&offset=${rowsPerPage *
                    page}`,
                setLoading,
                setError,
            }).then((respData) => {
                respData &&
                    setData({
                        total: respData?.total,
                        listing: [
                            ...respData?.folders.map((f) => ({
                                ...f,
                                type: "FOLDER",
                            })),
                            ...respData?.files.map((f) => ({
                                ...f,
                                type: "FILE",
                            })),
                        ].map((i) => camelcaseit(i)), // camelcase the fields for each object, for consistency.
                    });
                setError("");
            });
        }
    }, [path, rowsPerPage, orderBy, order, page, uploadsCompleted]);

    useEffect(() => {
        callApi({
            endpoint: `/api/filesystem/root`,
            setLoading,
            setError,
        }).then((respData) => {
            if (respData && userProfile) {
                const respRoots = respData.roots;
                const home = respRoots.find(
                    (root) => root.label === userProfile.id
                );
                home.icon = <HomeIcon />;
                const sharedWithMe = respRoots.find(
                    (root) => root.label === constants.SHARED_WITH_ME
                );
                setSharedWithMePath(sharedWithMe.path);
                sharedWithMe.icon = <FolderSharedIcon />;
                const communityData = respRoots.find(
                    (root) => root.label === constants.COMMUNITY_DATA
                );
                setCommunityDataPath(communityData.path);
                communityData.icon = <GroupIcon />;
                const trash = respRoots.find(
                    (root) => root.label === formatMessage(intl, "trash")
                );
                trash.icon = <DeleteIcon />;

                const basePaths = respData["base-paths"];
                setUserHomePath(basePaths["user_home_path"]);
                setUserTrashPath(basePaths["user_trash_path"]);
                setDataRoots([home, sharedWithMe, communityData, trash]);
            }
            setError("");
        });
    }, [path, intl, userProfile]);

    useEffect(() => {
        callApi({
            endpoint: `/api/filetypes/type-list`,
        }).then((resp) => {
            if (resp) {
                setInfoTypes(resp.types);
            }
        });
    }, []);

    useEffect(() => {
        setDetailsEnabled(selected && selected.length === 1);
    }, [selected]);

    const handleRequestSort = (event, property) => {
        const isAsc = orderBy === property && order === "asc";
        setOrder(isAsc ? "desc" : "asc");
        setOrderBy(property);
    };

    const handleSelectAllClick = (event) => {
        if (event.target.checked && !selected.length) {
            const newSelecteds =
                data?.listing?.map((resource) => resource.id) || [];
            setSelected(newSelecteds);
            return;
        }
        setSelected([]);
    };

    const toggleDisplay = () => {
        setGridView(!isGridView);
    };

    // Simple range select: if you shift-click a range, the range will be
    // selected.  If all items in the range are already selected, all items
    // will be deselected.
    const rangeSelect = (start, end, targetId) => {
        const rangeIds = [];
        for (let i = start; i <= end; i++) {
            rangeIds.push(data?.listing[i].id);
        }

        let isTargetSelected = selected.includes(targetId);

        isTargetSelected ? deselect(rangeIds) : select(rangeIds);
    };

    const handleClick = (event, id, index) => {
        if (event.shiftKey) {
            lastSelectIndex > index
                ? rangeSelect(index, lastSelectIndex, id)
                : rangeSelect(lastSelectIndex, index, id);
        } else {
            toggleSelection(id);
        }

        setLastSelectIndex(index);
    };

    const toggleSelection = (resourceId) => {
        if (selected.includes(resourceId)) {
            deselect([resourceId]);
        } else {
            select([resourceId]);
        }
    };

    const select = (resourceIds) => {
        let newSelected = [...selected];
        resourceIds.forEach((resourceId) => {
            const selectedIndex = selected.indexOf(resourceId);
            if (selectedIndex === -1) {
                newSelected.push(resourceId);
            }
        });

        setSelected(newSelected);
    };

    const deselect = (resourceIds) => {
        const newSelected = selected.filter(
            (selectedID) => !resourceIds.includes(selectedID)
        );

        setSelected(newSelected);
    };

    const onDownloadSelected = (resourceId) => {
        console.log("Download", resourceId);
    };

    const onEditSelected = (resourceId) => {
        console.log("Edit", resourceId);
    };

    const onMetadataSelected = (resourceId) => {
        console.log("Metadata", resourceId);
    };

    const onDeleteSelected = (resourceId) => {
        console.log("Delete", resourceId);
    };

    const handleChangePage = (event, newPage) => {
        setPage(newPage);
    };

    const handleChangeRowsPerPage = (event) => {
        setRowsPerPage(parseInt(event.target.value, 10));
        setPage(0);
    };

    //route to default path
    if (dataRoots.length > 0 && (!error || error.length === 0) && !path) {
        router.push(
            constants.PATH_SEPARATOR +
                NavigationConstants.DATA +
                constants.PATH_SEPARATOR +
                `ds${dataRoots[0].path}`
        );
    }

    const onDetailsSelected = () => {
        setDetailsOpen(true);
        const selectedId = selected[0];
        const resourceIndex = data.listing.findIndex(
            (item) => item.id === selectedId
        );
        const resource = data.listing[resourceIndex];
        setDetailsResource(resource);
    };

    return (
        <>
            <UploadDropTarget path={path}>
                <Header
                    baseId={baseId}
                    isGridView={isGridView}
                    toggleDisplay={toggleDisplay}
                    path={path}
                    error={error}
                    onDownloadSelected={onDownloadSelected}
                    onEditSelected={onEditSelected}
                    onMetadataSelected={onMetadataSelected}
                    onDeleteSelected={onDeleteSelected}
                    dataRoots={dataRoots}
                    userHomePath={userHomePath}
                    userTrashPath={userTrashPath}
                    sharedWithMePath={sharedWithMePath}
                    communityDataPath={communityDataPath}
                    detailsEnabled={detailsEnabled}
                    onDetailsSelected={onDetailsSelected}
                />
                {!isGridView && (
                    <TableView
                        loading={loading}
                        error={error}
                        path={path}
                        handlePathChange={handlePathChange}
                        listing={data?.listing}
                        baseId={baseId}
                        onDownloadSelected={onDownloadSelected}
                        onEditSelected={onEditSelected}
                        onMetadataSelected={onMetadataSelected}
                        onDeleteSelected={onDeleteSelected}
                        handleRequestSort={handleRequestSort}
                        handleSelectAllClick={handleSelectAllClick}
                        handleClick={handleClick}
                        order={order}
                        orderBy={orderBy}
                        selected={selected}
                    />
                )}
                {isGridView && <span>Coming Soon!</span>}
                <TablePagination
                    rowsPerPageOptions={[5, 10, 25]}
                    component="div"
                    count={data?.total}
                    rowsPerPage={rowsPerPage}
                    page={page}
                    onChangePage={handleChangePage}
                    onChangeRowsPerPage={handleChangeRowsPerPage}
                />
            </UploadDropTarget>
            {detailsOpen && (
                <Drawer
                    resource={detailsResource}
                    open={detailsOpen}
                    baseId={baseId}
                    infoTypes={infoTypes}
                    onClose={() => setDetailsOpen(false)}
                />
            )}
        </>
    );
}

export default withI18N(injectIntl(Listing), messages);
