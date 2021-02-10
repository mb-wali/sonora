/**
 * View text files
 *
 * @author sriram
 *
 */
import React, { useState } from "react";

import { LightAsync as SyntaxHighlighter } from "react-syntax-highlighter";
import highlightStyle from "react-syntax-highlighter/dist/cjs/styles/hljs/default-style";

import ids from "./ids";
import Toolbar from "./Toolbar";

import PageWrapper from "components/layout/PageWrapper";

import { build } from "@cyverse-de/ui-lib";

import {
    CircularProgress,
    FormControl,
    InputLabel,
    Select,
    MenuItem,
} from "@material-ui/core";

function ModeSelect(props) {
    const { mode, handleModeSelect } = props;
    const languages = SyntaxHighlighter.supportedLanguages;

    return (
        <FormControl>
            <InputLabel id="languageSelectLabel">Mode</InputLabel>
            <Select
                labelId="languageSelectLabel"
                id="languageSelect"
                value={mode}
                onChange={handleModeSelect}
            >
                {languages.map((language, index) => (
                    <MenuItem
                        value={language}
                        key={index}
                        id={"languageSelect" + language}
                    >
                        {language}
                    </MenuItem>
                ))}
            </Select>
        </FormControl>
    );
}

export default function TextViewer(props) {
    const {
        baseId,
        path,
        resourceId,
        data,
        loading,
        mode,
        handlePathChange,
        handleModeSelect,
        onRefresh,
        fileName,
    } = props;
    const [showLineNumbers, setShowLineNumbers] = useState(true);

    return (
        <PageWrapper
            appBarHeight={120}
            id={build(baseId, ids.VIEWER_PLAIN, fileName)}
        >
            <Toolbar
                baseId={build(baseId, ids.VIEWER_DOC, ids.TOOLBAR)}
                path={path}
                resourceId={resourceId}
                allowLineNumbers={true}
                showLineNumbers={showLineNumbers}
                onShowLineNumbers={(show) => setShowLineNumbers(show)}
                handlePathChange={handlePathChange}
                onRefresh={onRefresh}
                fileName={fileName}
            />
            {loading && (
                <CircularProgress
                    thickness={7}
                    color="primary"
                    style={{
                        position: "absolute",
                        top: "50%",
                        left: "50%",
                    }}
                />
            )}
            <ModeSelect mode={mode} handleModeSelect={handleModeSelect} />
            <SyntaxHighlighter
                customStyle={{
                    overflow: "auto",
                    width: "auto",
                }}
                language={mode}
                style={highlightStyle}
                showLineNumbers={showLineNumbers}
                showInlineLineNumbers={true}
                wrapLines={true}
            >
                {data}
            </SyntaxHighlighter>
        </PageWrapper>
    );
}
