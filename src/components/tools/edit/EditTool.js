/**
 * @author aramsey, sriram, psarando
 */
import React, { useState } from "react";

import { useTranslation } from "i18n";
import { useQuery, useMutation, queryCache } from "react-query";

import { formatSubmission, mapPropsToValues } from "./formatters";

import TOOL_TYPES from "components/models/ToolTypes";
import { useConfig } from "contexts/config";
import DEDialog from "components/utils/DEDialog";
import ContainerDevices from "./ContainerDevices";
import ContainerImage from "./ContainerImage";
import ContainerPorts from "./ContainerPorts";
import ContainerVolumes from "./ContainerVolumes";
import ContainerVolumesFrom from "./ContainerVolumesFrom";
import ids from "../ids";
import Restrictions from "./ToolRestrictions";
import styles from "../styles";
import ToolImplementation from "./ToolImplementation";
import { nonEmptyField } from "components/utils/validations";
import constants from "../../../constants";

import ErrorTypographyWithDialog from "components/error/ErrorTypographyWithDialog";

import {
    getToolTypes,
    addTool,
    updateTool,
    adminAddTool,
    adminUpdateTool,
    getToolDetails,
    TOOL_TYPES_QUERY_KEY,
    TOOL_DETAILS_QUERY_KEY,
    TOOLS_QUERY_KEY,
} from "serviceFacades/tools";

import buildID from "components/utils/DebugIDUtil";
import { announce } from "components/announcer/CyVerseAnnouncer";
import FormMultilineTextField from "components/forms/FormMultilineTextField";
import FormTextField from "components/forms/FormTextField";
import FormSelectField from "components/forms/FormSelectField";
import FormNumberField from "components/forms/FormNumberField";

import { Field, FieldArray, Form, Formik } from "formik";
import {
    Button,
    CircularProgress,
    Grid,
    MenuItem,
    Paper,
    Typography,
} from "@material-ui/core";
import { withStyles } from "@material-ui/core/styles";
import { Skeleton } from "@material-ui/lab";

function EditToolDialog(props) {
    const { open, parentId, tool, isAdmin, isAdminPublishing, onClose } = props;

    const { t } = useTranslation("tools");

    const [toolTypes, setToolTypes] = useState([]);
    const [addToolError, setAddToolError] = useState();
    const [updateToolError, setUpdateToolError] = useState();
    const [selectedTool, setSelectedTool] = useState();
    const [toolTypeQueryEnabled, setToolTypesQueryEnabled] = useState();

    const [config] = useConfig();
    const resourceConfigs = isAdmin
        ? config?.tools?.admin
        : config?.tools?.private;
    const maxCPUCore = resourceConfigs?.max_cpu_limit;
    const maxMemory = resourceConfigs?.max_memory_limit;
    const maxDiskSpace = resourceConfigs?.max_disk_limit;

    const toolTypesCache = queryCache.getQueryData(TOOL_TYPES_QUERY_KEY);

    const preProcessToolTypes = React.useCallback(
        (data) => {
            if (data?.tool_types?.length > 0) {
                setToolTypes(
                    data["tool_types"]
                        .filter(
                            (type) =>
                                type.name !== TOOL_TYPES.INTERNAL &&
                                type.name !== TOOL_TYPES.FAPI
                        )
                        .map((type) => type.name)
                );
            }
        },
        [setToolTypes]
    );

    React.useEffect(() => {
        if (toolTypesCache) {
            preProcessToolTypes(toolTypesCache);
        } else {
            setToolTypesQueryEnabled(true);
        }
    }, [preProcessToolTypes, toolTypesCache]);

    const { isFetching: isToolTypeFetching, error: toolTypeError } = useQuery({
        queryKey: TOOL_TYPES_QUERY_KEY,
        queryFn: getToolTypes,
        config: {
            enabled: toolTypeQueryEnabled,
            staleTime: Infinity,
            cacheTime: Infinity,
            onSuccess: preProcessToolTypes,
        },
    });
    const { isFetching: isToolFetching, error: toolFetchError } = useQuery({
        queryKey: [TOOL_DETAILS_QUERY_KEY, { id: tool?.id, isAdmin }],
        queryFn: getToolDetails,
        config: {
            enabled: tool && open,
            onSuccess: setSelectedTool,
        },
    });

    const [addNewTool, { status: newToolStatus }] = useMutation(
        ({ submission }) =>
            isAdmin ? adminAddTool(submission) : addTool(submission),
        {
            onSuccess: (data) => {
                announce({
                    text: t("toolAdded"),
                });
                queryCache.invalidateQueries(TOOLS_QUERY_KEY);
                setAddToolError(null);
                onClose();
            },
            onError: setAddToolError,
        }
    );

    const [updateCurrentTool, { status: updateToolStatus }] = useMutation(
        ({ submission }) =>
            isAdmin ? adminUpdateTool(submission) : updateTool(submission),
        {
            onSuccess: (data) => {
                announce({
                    text: t("toolUpdated"),
                });
                queryCache.invalidateQueries(TOOLS_QUERY_KEY);
                setUpdateToolError(null);
                onClose();
            },
            onError: setUpdateToolError,
        }
    );

    const handleSubmit = (values) => {
        const submission = formatSubmission(values, config, isAdmin);

        //avoid dupe submission
        if (
            newToolStatus !== constants.LOADING &&
            updateToolStatus !== constants.LOADING
        ) {
            if (tool) {
                updateCurrentTool({ submission });
            } else {
                addNewTool({ submission });
            }
        }
    };

    return (
        <Formik
            initialValues={mapPropsToValues(selectedTool, isAdmin)}
            onSubmit={handleSubmit}
            enableReinitialize={true}
        >
            {({ handleSubmit, values }) => {
                return (
                    <Form>
                        <DEDialog
                            open={open}
                            fullWidth={true}
                            onClose={onClose}
                            id={parentId}
                            title={
                                tool
                                    ? t("editTool", {
                                          name: tool.name,
                                      })
                                    : t("addTool")
                            }
                            actions={
                                <>
                                    <Button
                                        id={buildID(
                                            parentId,
                                            ids.BUTTONS.CANCEL
                                        )}
                                        onClick={onClose}
                                    >
                                        {t("cancel")}
                                    </Button>
                                    <Button
                                        id={buildID(parentId, ids.BUTTONS.SAVE)}
                                        type="submit"
                                        color="primary"
                                        onClick={handleSubmit}
                                    >
                                        {isAdminPublishing
                                            ? t("makePublic")
                                            : t("save")}
                                    </Button>
                                </>
                            }
                        >
                            {(isToolTypeFetching || isToolFetching) && (
                                <Skeleton
                                    animation="wave"
                                    variant="rect"
                                    height={800}
                                />
                            )}

                            {(newToolStatus === constants.LOADING ||
                                updateToolStatus === constants.LOADING) && (
                                <CircularProgress
                                    size={30}
                                    thickness={5}
                                    style={{
                                        position: "absolute",
                                        top: "50%",
                                        left: "50%",
                                    }}
                                />
                            )}

                            {toolTypeError && (
                                <ErrorTypographyWithDialog
                                    errorObject={toolTypeError}
                                    errorMessage={t("toolTypesFetchError")}
                                    baseId={parentId}
                                />
                            )}
                            {toolFetchError && (
                                <ErrorTypographyWithDialog
                                    errorObject={toolFetchError}
                                    errorMessage={t("toolInfoError")}
                                    baseId={parentId}
                                />
                            )}

                            {addToolError && (
                                <ErrorTypographyWithDialog
                                    errorObject={addToolError}
                                    errorMessage={t("toolAddError")}
                                />
                            )}
                            {updateToolError && (
                                <ErrorTypographyWithDialog
                                    errorObject={updateToolError}
                                    errorMessage={t("toolUpdateError")}
                                />
                            )}

                            {!isToolTypeFetching && !isToolFetching && (
                                <StyledEditToolForm
                                    isAdmin={isAdmin}
                                    parentId={parentId}
                                    toolTypes={toolTypes}
                                    maxCPUCore={maxCPUCore}
                                    maxMemory={maxMemory}
                                    maxDiskSpace={maxDiskSpace}
                                    values={values}
                                />
                            )}
                            <Grid
                                container
                                direction="row"
                                justifyContent="flex-end"
                                alignItems="flex-end"
                                spacing={1}
                            >
                                {toolTypeError && (
                                    <Grid item xs>
                                        <ErrorTypographyWithDialog
                                            errorObject={toolTypeError}
                                            errorMessage={t(
                                                "toolTypesFetchError"
                                            )}
                                            baseId={parentId}
                                        />
                                    </Grid>
                                )}
                                {toolFetchError && (
                                    <Grid item xs>
                                        <ErrorTypographyWithDialog
                                            errorObject={toolFetchError}
                                            errorMessage={t("toolInfoError")}
                                            baseId={parentId}
                                        />
                                    </Grid>
                                )}

                                {addToolError && (
                                    <Grid item xs>
                                        <ErrorTypographyWithDialog
                                            errorObject={addToolError}
                                            errorMessage={t("toolAddError")}
                                        />
                                    </Grid>
                                )}
                                {updateToolError && (
                                    <Grid item xs>
                                        <ErrorTypographyWithDialog
                                            errorObject={updateToolError}
                                            errorMessage={t("toolUpdateError")}
                                        />
                                    </Grid>
                                )}
                            </Grid>
                        </DEDialog>
                    </Form>
                );
            }}
        </Formik>
    );
}

const StyledEditToolForm = withStyles(styles)(EditToolForm);

function EditToolForm(props) {
    const {
        isAdmin,
        parentId,
        toolTypes,
        maxCPUCore,
        maxMemory,
        maxDiskSpace,
        classes,
        values,
    } = props;

    const { t } = useTranslation("tools");
    const { t: i18nUtil } = useTranslation("util");

    const selectedToolType = values.type;
    const isOSGTool = selectedToolType === TOOL_TYPES.OSG;
    const isInteractiveTool = selectedToolType === TOOL_TYPES.INTERACTIVE;

    return (
        <>
            <Field
                name="name"
                label={t("toolName")}
                id={buildID(parentId, ids.EDIT_TOOL_DLG.NAME)}
                required
                validate={(value) => nonEmptyField(value, i18nUtil)}
                component={FormTextField}
            />
            <Field
                name="description"
                label={t("toolDesc")}
                id={buildID(parentId, ids.EDIT_TOOL_DLG.DESCRIPTION)}
                component={FormMultilineTextField}
            />
            <Field
                name="version"
                label={t("toolVersion")}
                id={buildID(parentId, ids.EDIT_TOOL_DLG.VERSION)}
                required
                validate={(value) => nonEmptyField(value, i18nUtil)}
                component={FormTextField}
            />
            {isAdmin && (
                <Field
                    name="attribution"
                    label={t("attribution")}
                    id={buildID(parentId, ids.EDIT_TOOL_DLG.ATTRIBUTION)}
                    component={FormTextField}
                />
            )}
            {isAdmin && (
                <Field
                    name="location"
                    label={t("location")}
                    id={buildID(parentId, ids.EDIT_TOOL_DLG.LOCATION)}
                    component={FormTextField}
                />
            )}
            <Field name="type">
                {({ field: { onChange, ...field }, ...props }) => (
                    <FormSelectField
                        {...props}
                        label={t("type")}
                        required
                        field={field}
                        onChange={(event) => {
                            resetOnTypeChange(event.target.value, props.form);
                            onChange(event);
                        }}
                        id={buildID(parentId, ids.EDIT_TOOL_DLG.TYPE)}
                    >
                        {toolTypes.map((type, index) => (
                            <MenuItem
                                key={index}
                                value={type}
                                id={buildID(
                                    parentId,
                                    ids.EDIT_TOOL_DLG.TYPE,
                                    type
                                )}
                            >
                                {type}
                            </MenuItem>
                        ))}
                    </FormSelectField>
                )}
            </Field>
            {isAdmin && (
                <Field
                    name="implementation"
                    isAdmin={isAdmin}
                    parentId={buildID(
                        parentId,
                        ids.EDIT_TOOL_DLG.TOOL_IMPLEMENTATION
                    )}
                    component={ToolImplementation}
                />
            )}
            <Field
                name={"container.image"}
                parentId={parentId}
                isOSGTool={isOSGTool}
                component={ContainerImage}
            />
            {isAdmin && (
                <Field
                    name="container.name"
                    label={t("containerName")}
                    id={buildID(parentId, ids.EDIT_TOOL_DLG.CONTAINER_NAME)}
                    component={FormTextField}
                />
            )}
            {isAdmin && (
                <Paper elevation={1} classes={{ root: classes.paper }}>
                    <Typography variant="body2">
                        {t("entrypointWarning")}
                    </Typography>
                </Paper>
            )}
            <Field
                name="container.entrypoint"
                label={t("entrypoint")}
                id={buildID(parentId, ids.EDIT_TOOL_DLG.ENTRYPOINT)}
                component={FormTextField}
            />
            <Field
                name="container.working_directory"
                label={t("workingDirectory")}
                id={buildID(parentId, ids.EDIT_TOOL_DLG.WORKING_DIR)}
                component={FormTextField}
            />
            <Field
                name="container.uid"
                label={t("containerUID")}
                id={buildID(parentId, ids.EDIT_TOOL_DLG.CONTAINER_UID)}
                component={FormNumberField}
            />
            {(isAdmin || isInteractiveTool) && (
                <FieldArray
                    name="container.container_ports"
                    render={(arrayHelpers) => (
                        <ContainerPorts
                            isAdmin={isAdmin}
                            parentId={buildID(
                                parentId,
                                ids.EDIT_TOOL_DLG.CONTAINER_PORTS
                            )}
                            {...arrayHelpers}
                        />
                    )}
                />
            )}
            {isAdmin && (
                <FieldArray
                    name="container.container_devices"
                    render={(arrayHelpers) => (
                        <ContainerDevices
                            parentId={buildID(
                                parentId,
                                ids.EDIT_TOOL_DLG.CONTAINER_DEVICES
                            )}
                            {...arrayHelpers}
                        />
                    )}
                />
            )}
            {isAdmin && (
                <Paper elevation={1} classes={{ root: classes.paper }}>
                    <Typography variant="body2">
                        {t("volumesWarning")}
                    </Typography>
                </Paper>
            )}
            {isAdmin && (
                <FieldArray
                    name="container.container_volumes"
                    render={(arrayHelpers) => (
                        <ContainerVolumes
                            parentId={buildID(
                                parentId,
                                ids.EDIT_TOOL_DLG.CONTAINER_VOLUMES
                            )}
                            {...arrayHelpers}
                        />
                    )}
                />
            )}
            {isAdmin && (
                <FieldArray
                    name="container.container_volumes_from"
                    render={(arrayHelpers) => (
                        <ContainerVolumesFrom
                            parentId={buildID(
                                parentId,
                                ids.EDIT_TOOL_DLG.CONTAINER_VOLUMES
                            )}
                            {...arrayHelpers}
                        />
                    )}
                />
            )}
            <Field
                isAdmin={isAdmin}
                parentId={buildID(parentId, ids.EDIT_TOOL_DLG.RESTRICTIONS)}
                maxDiskSpace={maxDiskSpace}
                maxCPUCore={maxCPUCore}
                maxMemory={maxMemory}
                component={Restrictions}
            />
        </>
    );
}

/**
 * Ensures that if the user previously filled out information for an OSG
 * or interactive/VICE tool, and then selects a different type,
 * that those fields get cleared out to prevent any validation errors and
 * also to prevent empty values being unintentionally sent to the service.
 *
 * Also auto-sets the container.network_mode based on tool type
 *
 * @param currentType
 * @param form
 */
function resetOnTypeChange(currentType, form) {
    if (currentType !== TOOL_TYPES.OSG) {
        form.setFieldValue("container.image.osg_image_path", null);
    }
    if (currentType !== TOOL_TYPES.INTERACTIVE) {
        form.setFieldValue("container.container_ports", []);
        form.setFieldValue("container.network_mode", "none");
    } else {
        form.setFieldValue("container.network_mode", "bridge");
    }
}

export default EditToolDialog;
